# LinkSentry

A Telegram bot that monitors your links and notifies you when they go down.

## What it does

LinkSentry checks your websites and APIs regularly. When something breaks, it sends you a message on Telegram so you can fix it quickly.

## Try it out

Use the bot: [@link_sentry_bot](https://t.me/link_sentry_bot)

## Commands

- `/start` - Get started with the bot
- `/add <url>` - Add a link to monitor
- `/list` - See all your monitored links
- `/remove <id>` - Stop monitoring a link
- `/status` - Check current status of your links

## Features

- Monitors HTTPS links
- Simple setup - just send a link
- Instant notifications when sites go down or come back up
- Free to use

## Development

Built with:

- Elixir
- SQLite database

### Running locally

1. Clone the repo
2. Install dependencies: `mix deps.get`
3. Set your bot token: `export TELEGRAM_BOT_TOKEN=your_token`
4. Run migrations: `mix ecto.migrate`
5. Start the bot: `mix run --no-halt`

### Testing

```bash
mix test
```

## Deployment

The bot runs as a standalone Elixir application.

## Contributing

Feel free to open issues or submit pull requests. Keep it simple and focused on link monitoring.

## License

AGPL-3.0
