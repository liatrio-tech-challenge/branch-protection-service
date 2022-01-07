const {Octokit} = require('@octokit/rest');
const {verify} = require('@octokit/webhooks-methods');

module.exports = async (context, req) => {
    context.res = {status: 200};
    if (req.method === 'GET') {
        context.res.body = 'healthy';
        return
    }

    if (!process.env.GITHUB_TOKEN) {
        console.error('The environment variable $GITHUB_TOKEN must be set.');
        context.res.status = 500;
        return;
    }

    if (!process.env.WEBHOOK_SECRET) {
        console.error('The environment variable $WEBHOOK_SECRET must be set.');
        context.res.status = 500;
        return;
    }

    const eventType = req.headers['x-github-event'];
    const eventAction = req.body.action;
    console.log(`Received event type ${eventType} with action ${eventAction}`);

    const signature = req.headers['x-hub-signature-256'];
    if (!signature) {
        console.log('Request with no signature ignored');
        context.res.status = 401;
        return;
    }
    console.log(`Webhook signature ${signature}`);

    const isGitHubRequest = await verify(process.env.WEBHOOK_SECRET, JSON.stringify(req.body), signature);
    if (!isGitHubRequest) {
        console.log('Request with invalid signature ignored');
        context.res.status = 401;
        return;
    }

    if (!(eventType === 'repository' && eventAction === 'created')) {
        console.log('Unexpected webhook event, ignoring');
        return;
    }

    const octokit = new Octokit({
        auth: process.env.GITHUB_TOKEN,
    });

    const sender = req.body.sender.login;
    const owner = req.body.repository.owner.login;
    const repo = req.body.repository.name;
    const branch = 'main'; // TODO: req.body.repository.default_branch is incorrect, try to query for repository
    console.log('repo settings', {
        sender,
        owner,
        repo,
        branch,
    })

    try {
        console.log(`Configuring branch protections for repo '${repo}'`);
        await octokit.rest.repos.updateBranchProtection({
            owner,
            repo,
            branch,
            required_status_checks: {
                contexts: [],
                strict: true,
            },
            enforce_admins: true,
            required_pull_request_reviews: {
                dismiss_stale_reviews: true,
                required_approving_review_count: 1,
            },
            required_linear_history: true,
            allow_force_pushes: false,
            allow_deletions: false,
            required_conversation_resolution: true,
            restrictions: null,
        });

        console.log(`Posting issue comment for repo '${repo}'`);
        await octokit.rest.issues.create({
            owner,
            repo,
            title: `${repo} configured by branch-protection service`,
            body: `@${sender} branch protections have been enabled for \`${branch}\` in the repository: \`${repo}\``,
        });
    } catch (error) {
        console.error('Error sending GitHub request' + error.stack);
        context.res.status = 500;
        return;
    }

    console.log('Successfully configured branch protections and notified creator');
    context.res = {
        status: 200,
    };
}
