curl -X POST -H 'Content-type: application/json' --data '{
    "blocks": [
        {
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": "🚀 Build has started: '$PROJECT' ",
                "emoji": true
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
                    "text": "*Started at:*\n `'"$(date +"%T")"'`"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Triggered By:*\n '"$CODEBUILD_INITIATOR"'"
                }
            ]
        },
        {
            "type": "divider"
        }
    ]
}' $SLACK_WEBHOOK_URL