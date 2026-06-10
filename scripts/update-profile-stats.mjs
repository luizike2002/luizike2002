import fs from 'node:fs/promises';

const login = process.env.GITHUB_LOGIN || 'luizike2002';
const token = process.env.PROFILE_STATS_TOKEN || process.env.GITHUB_TOKEN;
const readmePath = process.env.README_PATH || 'README.md';
const includeForks = process.env.INCLUDE_FORKS === 'true';

if (!token) {
  throw new Error('Defina PROFILE_STATS_TOKEN com acesso de leitura aos repositorios que devem entrar no calculo.');
}

const restHeaders = {
  authorization: `Bearer ${token}`,
  accept: 'application/vnd.github+json',
  'x-github-api-version': '2022-11-28',
  'user-agent': 'profile-stats-updater'
};

const graphqlHeaders = {
  authorization: `Bearer ${token}`,
  accept: 'application/vnd.github+json',
  'user-agent': 'profile-stats-updater'
};

async function rest(path) {
  const response = await fetch(`https://api.github.com${path}`, { headers: restHeaders });
  if (!response.ok) {
    const body = await response.text();
    throw new Error(`GitHub REST ${response.status} em ${path}: ${body}`);
  }
  return response.json();
}

async function paginate(path) {
  const output = [];
  for (let page = 1; page <= 20; page += 1) {
    const separator = path.includes('?') ? '&' : '?';
    const pageItems = await rest(`${path}${separator}per_page=100&page=${page}`);
    if (!Array.isArray(pageItems) || pageItems.length === 0) break;
    output.push(...pageItems);
    if (pageItems.length < 100) break;
  }
  return output;
}

async function graphql(query, variables) {
  const response = await fetch('https://api.github.com/graphql', {
    method: 'POST',
    headers: graphqlHeaders,
    body: JSON.stringify({ query, variables })
  });

  const body = await response.json();
  if (!response.ok || body.errors) {
    throw new Error(`GitHub GraphQL falhou: ${JSON.stringify(body.errors || body)}`);
  }
  return body.data;
}

async function listOwnedRepositories() {
  const repositories = await paginate('/user/repos?affiliation=owner&visibility=all&sort=updated&direction=desc');
  return repositories
    .filter((repo) => repo.owner?.login?.toLowerCase() === login.toLowerCase())
    .filter((repo) => includeForks || !repo.fork)
    .filter((repo) => !repo.archived);
}

async function getLanguages(repositories) {
  const totals = new Map();
  const skipped = [];

  for (const repo of repositories) {
    try {
      const languages = await rest(`/repos/${repo.full_name}/languages`);
      for (const [language, bytes] of Object.entries(languages)) {
        totals.set(language, (totals.get(language) || 0) + Number(bytes || 0));
      }
    } catch (error) {
      skipped.push(repo.full_name);
      console.warn(`Nao foi possivel ler linguagens de ${repo.full_name}: ${error.message}`);
    }
  }

  const totalBytes = [...totals.values()].reduce((sum, value) => sum + value, 0);
  const ranking = [...totals.entries()]
    .map(([language, bytes]) => ({ language, bytes, percentage: totalBytes ? (bytes / totalBytes) * 100 : 0 }))
    .sort((a, b) => b.bytes - a.bytes);

  return { ranking, totalBytes, skipped };
}

async function getContributionDays() {
  const to = new Date();
  const from = new Date(to);
  from.setUTCDate(from.getUTCDate() - 366);

  const query = `
    query ContributionCalendar($login: String!, $from: DateTime!, $to: DateTime!) {
      user(login: $login) {
        contributionsCollection(from: $from, to: $to) {
          contributionCalendar {
            totalContributions
            weeks {
              contributionDays {
                date
                contributionCount
              }
            }
          }
        }
      }
    }
  `;

  const data = await graphql(query, {
    login,
    from: from.toISOString(),
    to: to.toISOString()
  });

  const calendar = data.user.contributionsCollection.contributionCalendar;
  const days = calendar.weeks
    .flatMap((week) => week.contributionDays)
    .sort((a, b) => a.date.localeCompare(b.date));

  return { totalContributions: calendar.totalContributions, days };
}

function calculateStreaks(days) {
  let longest = { count: 0, start: null, end: null };
  let currentRun = { count: 0, start: null, end: null };

  for (const day of days) {
    if (day.contributionCount > 0) {
      if (currentRun.count === 0) currentRun.start = day.date;
      currentRun.count += 1;
      currentRun.end = day.date;
    } else if (currentRun.count > 0) {
      if (currentRun.count > longest.count) longest = { ...currentRun };
      currentRun = { count: 0, start: null, end: null };
    }
  }

  if (currentRun.count > longest.count) longest = { ...currentRun };

  const today = new Date().toISOString().slice(0, 10);
  let index = days.findIndex((day) => day.date === today);
  if (index === -1) index = days.length - 1;

  let current = { count: 0, start: null, end: null };
  if (days[index]?.contributionCount > 0) {
    current.end = days[index].date;
    for (let i = index; i >= 0 && days[i].contributionCount > 0; i -= 1) {
      current.count += 1;
      current.start = days[i].date;
    }
  }

  return { current, longest };
}

function formatDate(date) {
  if (!date) return '-';
  const [year, month, day] = date.split('-');
  return `${day}/${month}/${year}`;
}

function formatNumber(value) {
  return new Intl.NumberFormat('pt-BR').format(value);
}

function formatPercent(value) {
  return `${value.toFixed(1).replace('.', ',')}%`;
}

function formatStreak(streak) {
  if (!streak.count) return '0 dias';
  return `${streak.count} dia${streak.count === 1 ? '' : 's'} (${formatDate(streak.start)} a ${formatDate(streak.end)})`;
}

function renderStats({ repositories, languageStats, contributionStats, streaks }) {
  const privateCount = repositories.filter((repo) => repo.private).length;
  const publicCount = repositories.length - privateCount;
  const topLanguage = languageStats.ranking[0];

  const languageRows = languageStats.ranking.slice(0, 8).map((item) => (
    `| ${item.language} | ${formatNumber(item.bytes)} | ${formatPercent(item.percentage)} |`
  ));

  const generatedAt = new Date().toISOString().replace('T', ' ').slice(0, 16);

  return `<!-- PROFILE-STATS:START -->
| Métrica | Valor calculado |
|---|---:|
| Repositórios analisados | ${repositories.length} (${publicCount} públicos / ${privateCount} privados) |
| Linguagem mais usada | ${topLanguage ? `${topLanguage.language} (${formatPercent(topLanguage.percentage)})` : 'Sem código detectado'} |
| Contribuições nos últimos 12 meses | ${formatNumber(contributionStats.totalContributions)} |
| Streak atual | ${formatStreak(streaks.current)} |
| Maior streak nos últimos 12 meses | ${formatStreak(streaks.longest)} |

### Linguagens por bytes

| Linguagem | Bytes | Participação |
|---|---:|---:|
${languageRows.length ? languageRows.join('\n') : '| Sem código detectado | 0 | 0,0% |'}

<sub>Atualizado automaticamente em ${generatedAt} UTC usando a API do GitHub e os repositórios acessíveis pelo token do workflow.</sub>
<!-- PROFILE-STATS:END -->`;
}

async function main() {
  const readme = await fs.readFile(readmePath, 'utf8');
  const start = '<!-- PROFILE-STATS:START -->';
  const end = '<!-- PROFILE-STATS:END -->';

  if (!readme.includes(start) || !readme.includes(end)) {
    throw new Error(`O README precisa conter os marcadores ${start} e ${end}.`);
  }

  const repositories = await listOwnedRepositories();
  const languageStats = await getLanguages(repositories);
  const contributionStats = await getContributionDays();
  const streaks = calculateStreaks(contributionStats.days);
  const renderedStats = renderStats({ repositories, languageStats, contributionStats, streaks });

  const nextReadme = readme.replace(new RegExp(`${start}[\\s\\S]*?${end}`), renderedStats);
  await fs.writeFile(readmePath, nextReadme);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
