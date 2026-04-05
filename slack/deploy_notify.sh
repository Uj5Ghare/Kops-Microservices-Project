curl -X POST -H 'Content-type: application/json' --data '{
    "blocks": [
        {
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": "✅ Deployment Successful: '"$PROJECT"'",
                "emoji": true
            }
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": ":sparkles: *A new version has been deployed!* Below are the details:"
            }
        },
        {
            "type": "section",
            "fields": [
                {
                    "type": "mrkdwn",
                    "text": "*Version:*\n`'"$TAG"'`"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Branch:*\n`'"$SLACK_NOTIFY_BRANCH"'`"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Source:*\nCodeCommit"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Environment:*\n '"$ENV"'"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Ended at:*\n `'"$(date +"%T")"'`"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Triggered By:*\n '"$CODEBUILD_INITIATOR"'"
                }
            ]
        },
        {
            "type": "context",
            "elements": [
                {
                    "type": "mrkdwn",
                    "text": "🕐 Completed at: '"$(date)"'"
                }
            ]
        },
        {
            "type": "divider"
        }
    ]
}' $SLACK_WEBHOOK_URL