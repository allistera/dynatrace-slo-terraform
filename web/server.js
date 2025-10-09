const express = require('express');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.urlencoded({ extended: true }));

const terraformVariables = [
  {
    name: 'dynatrace_environment_url',
    label: 'Dynatrace Environment URL',
    type: 'string',
    description: 'Dynatrace environment URL (e.g., https://abc12345.live.dynatrace.com)',
    required: true
  },
  {
    name: 'dynatrace_api_token',
    label: 'Dynatrace API Token',
    type: 'string',
    description: 'Dynatrace API token with SLO write permissions',
    required: true,
    sensitive: true
  },
  {
    name: 'service_name',
    label: 'Service Name',
    type: 'string',
    description: 'Name of the service to create SLOs for',
    defaultValue: 'TodoService'
  },
  {
    name: 'timeframe',
    label: 'Timeframe',
    type: 'string',
    description: 'Timeframe for SLO evaluation (e.g., -1w for 1 week)',
    defaultValue: '-1w'
  },
  {
    name: 'latency_target',
    label: 'Latency Target (%)',
    type: 'number',
    description: 'Target percentage for latency SLO (e.g., 95.0 means 95%)',
    defaultValue: 95.0
  },
  {
    name: 'latency_warning',
    label: 'Latency Warning (%)',
    type: 'number',
    description: 'Warning threshold for latency SLO',
    defaultValue: 97.0
  },
  {
    name: 'latency_threshold_ms',
    label: 'Latency Threshold (ms)',
    type: 'number',
    description: 'Latency threshold in milliseconds',
    defaultValue: 500
  },
  {
    name: 'latency_percentile',
    label: 'Latency Percentile',
    type: 'number',
    description: 'Percentile to use for latency measurement (50, 90, 95, 99)',
    defaultValue: 95
  },
  {
    name: 'availability_target',
    label: 'Availability Target (%)',
    type: 'number',
    description: 'Target percentage for availability SLO',
    defaultValue: 99.9
  },
  {
    name: 'availability_warning',
    label: 'Availability Warning (%)',
    type: 'number',
    description: 'Warning threshold for availability SLO',
    defaultValue: 99.95
  },
  {
    name: 'traffic_target',
    label: 'Traffic Target (%)',
    type: 'number',
    description: 'Target percentage for traffic throughput SLO',
    defaultValue: 90.0
  },
  {
    name: 'traffic_warning',
    label: 'Traffic Warning (%)',
    type: 'number',
    description: 'Warning threshold for traffic SLO',
    defaultValue: 95.0
  },
  {
    name: 'traffic_threshold_rpm',
    label: 'Traffic Threshold (requests/min)',
    type: 'number',
    description: 'Expected traffic threshold in requests per minute',
    defaultValue: 100
  },
  {
    name: 'error_rate_target',
    label: 'Error Rate Target (%)',
    type: 'number',
    description: 'Target percentage for error rate SLO (percentage of successful requests)',
    defaultValue: 99.5
  },
  {
    name: 'error_rate_warning',
    label: 'Error Rate Warning (%)',
    type: 'number',
    description: 'Warning threshold for error rate SLO',
    defaultValue: 99.8
  },
  {
    name: 'service_url',
    label: 'Service URL',
    type: 'string',
    description: 'URL of the service to monitor',
    defaultValue: 'http://3.250.34.74/'
  },
  {
    name: 'synthetic_locations',
    label: 'Synthetic Locations',
    type: 'list(string)',
    description: 'List of Dynatrace synthetic location IDs (one per line)',
    defaultValue: ['GEOLOCATION-871416B95457AB88']
  },
  {
    name: 'enable_guardian',
    label: 'Enable Site Reliability Guardian',
    type: 'bool',
    description: 'Whether to create a Site Reliability Guardian for the service',
    defaultValue: true
  },
  {
    name: 'guardian_name',
    label: 'Guardian Name',
    type: 'string',
    description: 'Optional override for the Site Reliability Guardian name',
    defaultValue: null
  },
  {
    name: 'guardian_description',
    label: 'Guardian Description',
    type: 'string',
    description: 'Optional description for the Site Reliability Guardian',
    defaultValue: null
  },
  {
    name: 'guardian_event_kind',
    label: 'Guardian Event Kind',
    type: 'string',
    description: 'Event kind to use when recording guardian evaluations',
    defaultValue: 'BIZ_EVENT'
  },
  {
    name: 'guardian_tags',
    label: 'Guardian Tags',
    type: 'list(string)',
    description: 'Additional tags to attach to the Site Reliability Guardian (one per line)',
    defaultValue: []
  }
];

const defaultFormValues = terraformVariables.reduce(
  (acc, variable) => {
    if (variable.defaultValue === undefined || variable.defaultValue === null) {
      acc[variable.name] = '';
    } else if (Array.isArray(variable.defaultValue)) {
      acc[variable.name] = variable.defaultValue.join('\n');
    } else {
      acc[variable.name] = String(variable.defaultValue);
    }
    return acc;
  },
  {}
);

function escapeHtml(value = '') {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function renderForm({ errors = [], values = {} } = {}) {
  const mergedValues = {
    base_branch: 'main',
    new_branch: '',
    commit_message: 'Add terraform.tfvars',
    file_path: 'terraform.tfvars',
    ...defaultFormValues,
    ...values
  };

  const terraformFieldsHtml = terraformVariables
    .map((variable) => {
      const formValue = mergedValues[variable.name] ?? '';
      const commonAttributes = `id="${variable.name}" name="${variable.name}" ${
        variable.required ? 'required' : ''
      }`;
      const helpText = variable.description
        ? `<p class="help">${escapeHtml(variable.description)}</p>`
        : '';

      if (variable.type === 'bool') {
        const currentValue =
          formValue === '' ? String(variable.defaultValue ?? false) : String(formValue);
        return `<div class="form-control">
  <label for="${variable.name}">${escapeHtml(variable.label)}</label>
  <select ${commonAttributes}>
    <option value="true" ${currentValue === 'true' ? 'selected' : ''}>true</option>
    <option value="false" ${currentValue === 'false' ? 'selected' : ''}>false</option>
  </select>
  ${helpText}
</div>`;
      }

      if (variable.type.startsWith('list')) {
        return `<div class="form-control">
  <label for="${variable.name}">${escapeHtml(variable.label)}</label>
  <textarea ${commonAttributes} rows="3" placeholder="One value per line">${escapeHtml(
    formValue
  )}</textarea>
  ${helpText}
</div>`;
      }

      const inputType = variable.type === 'number' ? 'number' : 'text';
      const extraAttributes = inputType === 'number' ? ' step="any"' : '';
      const currentValue =
        formValue === '' && variable.defaultValue !== undefined && variable.defaultValue !== null
          ? variable.defaultValue
          : formValue;

      return `<div class="form-control">
  <label for="${variable.name}">${escapeHtml(variable.label)}</label>
  <input type="${inputType}"${extraAttributes} ${commonAttributes} value="${escapeHtml(
        String(currentValue ?? '')
      )}" />
  ${helpText}
</div>`;
    })
    .join('\n');

  const errorsHtml = errors.length
    ? `<div class="errors">
  <h2>Fix these issues:</h2>
  <ul>${errors.map((error) => `<li>${escapeHtml(error)}</li>`).join('')}</ul>
</div>`
    : '';

  return `<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Terraform tfvars form</title>
    <style>
      body { font-family: Arial, sans-serif; margin: 0; padding: 0; background: #f5f5f5; }
      header { background: #243b53; color: #fff; padding: 1.5rem 2rem; }
      main { max-width: 960px; margin: 2rem auto; background: #fff; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 8px rgba(15, 23, 42, 0.1); }
      form { display: grid; gap: 1.5rem; }
      fieldset { border: 1px solid #d8dde6; padding: 1.5rem; border-radius: 6px; }
      legend { font-weight: bold; padding: 0 0.5rem; }
      .form-control { display: flex; flex-direction: column; gap: 0.5rem; }
      label { font-weight: 600; }
      input[type="text"], input[type="number"], textarea { padding: 0.75rem; border: 1px solid #cbd2d9; border-radius: 4px; font-size: 1rem; }
      select { padding: 0.75rem; border: 1px solid #cbd2d9; border-radius: 4px; font-size: 1rem; }
      button { background: #2680c2; border: none; color: #fff; padding: 0.75rem 1.5rem; font-size: 1rem; border-radius: 4px; cursor: pointer; }
      button:hover { background: #186faf; }
      .help { margin: 0; color: #52606d; font-size: 0.9rem; }
      .errors { border-left: 4px solid #e12d39; background: #fee2e2; padding: 1rem 1.5rem; border-radius: 4px; }
      .errors h2 { margin-top: 0; color: #9b1c1c; }
      ul { margin: 0; padding-left: 1.5rem; }
    </style>
  </head>
  <body>
    <header>
      <h1>Create terraform.tfvars branch</h1>
      <p>Fill in the Terraform variables and GitHub details to generate a new branch containing the tfvars file.</p>
    </header>
    <main>
      ${errorsHtml}
      <form method="post" action="/submit" autocomplete="off">
        <fieldset>
          <legend>GitHub details</legend>
          <div class="form-control">
            <label for="github_token">GitHub Personal Access Token</label>
            <input type="password" id="github_token" name="github_token" required />
            <p class="help">Token must allow repo access. It is only used to call the GitHub API and is not stored.</p>
          </div>
          <div class="form-control">
            <label for="repo_owner">Repository Owner or Organization</label>
            <input type="text" id="repo_owner" name="repo_owner" required value="${escapeHtml(
              mergedValues.repo_owner ?? ''
            )}" />
          </div>
          <div class="form-control">
            <label for="repo_name">Repository Name</label>
            <input type="text" id="repo_name" name="repo_name" required value="${escapeHtml(
              mergedValues.repo_name ?? ''
            )}" />
          </div>
          <div class="form-control">
            <label for="base_branch">Base Branch</label>
            <input type="text" id="base_branch" name="base_branch" required value="${escapeHtml(
              mergedValues.base_branch
            )}" />
          </div>
          <div class="form-control">
            <label for="new_branch">New Branch Name</label>
            <input type="text" id="new_branch" name="new_branch" required value="${escapeHtml(
              mergedValues.new_branch ?? ''
            )}" />
          </div>
          <div class="form-control">
            <label for="commit_message">Commit Message</label>
            <input type="text" id="commit_message" name="commit_message" required value="${escapeHtml(
              mergedValues.commit_message
            )}" />
          </div>
          <div class="form-control">
            <label for="file_path">tfvars File Path</label>
            <input type="text" id="file_path" name="file_path" required value="${escapeHtml(
              mergedValues.file_path
            )}" />
          </div>
        </fieldset>
        <fieldset>
          <legend>Terraform variables</legend>
          ${terraformFieldsHtml}
        </fieldset>
        <div>
          <button type="submit">Create Branch</button>
        </div>
      </form>
    </main>
  </body>
</html>`;
}

function parseList(rawValue, variable) {
  if (rawValue === undefined || rawValue === null) {
    return [];
  }

  if (Array.isArray(rawValue)) {
    return rawValue;
  }

  const values = String(rawValue)
    .split(/\r?\n|,/)
    .map((segment) => segment.trim())
    .filter((segment) => segment.length > 0);

  if (!values.length && Array.isArray(variable.defaultValue)) {
    return variable.defaultValue;
  }

  return values;
}

function formatValue(variable, rawValue) {
  const trimmedValue =
    typeof rawValue === 'string' && variable.type !== 'list(string)'
      ? rawValue.trim()
      : rawValue;

  let valueToUse = trimmedValue;

  if (valueToUse === '' || valueToUse === undefined) {
    if (variable.defaultValue !== undefined) {
      valueToUse = variable.defaultValue;
    } else if (variable.required) {
      throw new Error(`${variable.label} is required`);
    } else {
      return undefined;
    }
  }

  switch (variable.type) {
    case 'string': {
      if (valueToUse === null || valueToUse === 'null') {
        return 'null';
      }
      const asString = String(valueToUse);
      const escaped = asString.replace(/\\/g, '\\\\').replace(/"/g, '\\"');
      return `"${escaped}"`;
    }
    case 'number': {
      const parsed = Number(valueToUse);
      if (Number.isNaN(parsed)) {
        throw new Error(`${variable.label} must be a number`);
      }
      return String(parsed);
    }
    case 'bool': {
      const normalized =
        typeof valueToUse === 'boolean'
          ? valueToUse
          : ['true', '1', 'yes', 'on'].includes(String(valueToUse).toLowerCase());
      return normalized ? 'true' : 'false';
    }
    case 'list(string)': {
      const values = parseList(valueToUse, variable);
      const quoted = values.map((entry) => {
        const escaped = entry.replace(/\\/g, '\\\\').replace(/"/g, '\\"');
        return `"${escaped}"`;
      });
      return `[${quoted.join(', ')}]`;
    }
    default:
      throw new Error(`Unsupported variable type: ${variable.type}`);
  }
}

function buildTfvarsContent(formValues) {
  const lines = [];
  const errors = [];

  terraformVariables.forEach((variable) => {
    try {
      const formattedValue = formatValue(variable, formValues[variable.name]);
      if (formattedValue !== undefined) {
        lines.push(`${variable.name} = ${formattedValue}`);
      }
    } catch (error) {
      errors.push(error.message);
    }
  });

  return {
    content: lines.join('\n') + '\n',
    errors
  };
}

function renderSuccess({ branchName, filePath, commitMessage, tfvarsContent }) {
  return `<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Branch created</title>
    <style>
      body { font-family: Arial, sans-serif; background: #f5f5f5; margin: 0; padding: 0; }
      main { max-width: 960px; margin: 2rem auto; background: #fff; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 8px rgba(15, 23, 42, 0.1); }
      pre { background: #1f2933; color: #e0fcff; padding: 1.5rem; border-radius: 4px; overflow-x: auto; font-size: 0.95rem; }
      a.button { display: inline-block; margin-top: 1.5rem; padding: 0.75rem 1.5rem; background: #2680c2; color: #fff; border-radius: 4px; text-decoration: none; }
    </style>
  </head>
  <body>
    <main>
      <h1>Success!</h1>
      <p>Created branch <strong>${escapeHtml(branchName)}</strong> with <code>${escapeHtml(
        filePath
      )}</code>.</p>
      <p>Commit message: <code>${escapeHtml(commitMessage)}</code></p>
      <h2>Generated terraform.tfvars</h2>
      <pre>${escapeHtml(tfvarsContent)}</pre>
      <a class="button" href="/">Create another branch</a>
    </main>
  </body>
</html>`;
}

app.get('/', (_req, res) => {
  res.send(renderForm());
});

app.post('/submit', async (req, res) => {
  const {
    github_token: githubToken,
    repo_owner: repoOwner,
    repo_name: repoName,
    base_branch: baseBranch,
    new_branch: newBranch,
    commit_message: commitMessage,
    file_path: filePath
  } = req.body;

  const { content: tfvarsContent, errors: validationErrors } = buildTfvarsContent(req.body);

  const missingFields = [];
  if (!githubToken) missingFields.push('GitHub personal access token is required');
  if (!repoOwner) missingFields.push('Repository owner is required');
  if (!repoName) missingFields.push('Repository name is required');
  if (!baseBranch) missingFields.push('Base branch is required');
  if (!newBranch) missingFields.push('New branch name is required');
  if (!commitMessage) missingFields.push('Commit message is required');
  if (!filePath) missingFields.push('tfvars file path is required');

  const errors = [...validationErrors, ...missingFields];

  if (errors.length) {
    const safeValues = { ...req.body };
    safeValues.github_token = '';
    return res.status(400).send(
      renderForm({
        errors,
        values: safeValues
      })
    );
  }

  try {
    const api = axios.create({
      baseURL: 'https://api.github.com',
      headers: {
        Authorization: `token ${githubToken}`,
        'User-Agent': 'terraform-tfvars-generator',
        Accept: 'application/vnd.github+json'
      },
      timeout: 10000
    });

    const referenceResponse = await api.get(
      `/repos/${repoOwner}/${repoName}/git/refs/heads/${encodeURIComponent(baseBranch)}`
    );
    const baseSha = referenceResponse.data.object.sha;

    await api.post(`/repos/${repoOwner}/${repoName}/git/refs`, {
      ref: `refs/heads/${newBranch}`,
      sha: baseSha
    });

    await api.put(`/repos/${repoOwner}/${repoName}/contents/${filePath}`, {
      message: commitMessage,
      content: Buffer.from(tfvarsContent, 'utf8').toString('base64'),
      branch: newBranch
    });

    res.send(
      renderSuccess({
        branchName: newBranch,
        filePath,
        commitMessage,
        tfvarsContent
      })
    );
  } catch (error) {
    const apiErrorMessages = [];

    if (error.response) {
      const statusText = `${error.response.status} ${error.response.statusText}`;
      apiErrorMessages.push(`GitHub API error: ${statusText}`);

      if (error.response.data && typeof error.response.data.message === 'string') {
        apiErrorMessages.push(error.response.data.message);
      }

      if (Array.isArray(error.response.data?.errors)) {
        error.response.data.errors.forEach((err) => {
          if (typeof err.message === 'string') {
            apiErrorMessages.push(err.message);
          }
        });
      }
    } else if (error.request) {
      apiErrorMessages.push('No response received from GitHub API. Check network connectivity.');
    } else {
      apiErrorMessages.push(error.message);
    }

    const safeValues = { ...req.body };
    safeValues.github_token = '';

    res.status(500).send(
      renderForm({
        errors: apiErrorMessages,
        values: safeValues
      })
    );
  }
});

app.listen(PORT, () => {
  // eslint-disable-next-line no-console
  console.log(`Terraform tfvars helper listening on http://localhost:${PORT}`);
});
