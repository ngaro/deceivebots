# Nginx Bot Deceiver

This repo is meant to be used with nginx to treat bots in a different way then regular users.<br>_(Trick them, block them, redirect them, ...)._

We use the, regularly updated, json from the [monperrus/crawler-user-agents](https://github.com/monperrus/crawler-user-agents/blob/master/crawler-user-agents.json) repo to create a nginx-compatible config to identify bots by their user agent.
An example on how to use it is included.

---

## Setup Guide

### Learn from the example
It's strongly recommended to **take a look at the example** in the [example](example) directory.<br>
If you have docker installed you can run it with `./nginxInDocker.sh` _(make sure that you are inside the `example` dir when you run it)_.

This example treats regular browsers in a "standard" way but shows a completely different page to bots in such a way that they can't (easily) notice it.
The files inside that dir should give you a good idea how everything works.

To do other things with bots you can follow the steps below:

### 1. Update the list with bots
By running `./createNginxBotUARegexps.pl` the file `blocked-user-agents.conf` that contains regex patterns for user agents of all known bots is updated.
It's recommend to run this again every month or so (and restart nginx) to keep this list up to date. You might want to use a cron job or a systemd timer to automate it.<br>
A pre-generated list is already available in this repo, but it may be outdated. (It has been generated in february 2026)

### 2. Tell nginx about the bots
Put the block below in your main nginx config _(This should be `/etc/nginx/nginx.conf` )_.<br>
You might want to use `/etc/nginx/blocked-user-agents.conf` instead of pointing to this repo. In that case make sure that after running `./createNginxBotUARegexps.pl` the `blocked-user-agents.conf` file is copied inside `/etc/nginx`

```nginx
map $http_user_agent $is_a_bot {
    include /path/to/this/repo/blocked-user-agents.conf;
}
```

### 3. Apply the block in the per-site configs
This depends a bit on what you actually want to do. Usually you will start the site-configs in `/etc/nginx/conf.d/` with something like this:

```nginx
map $is_a_bot $bot_or_not_setting {
    default "SOMETHING FOR REAL BROWSERS";
    1 "SOMETHING FOR BOTS";
}
```

and then use the `$bot_or_not_setting` in your config to do different things for bots and real browsers.
Again: Take a look at the example for inspiration.

---

##  Contributing
- Extra user agents that should be blocked are handled in the [monperrus/crawler-user-agents](https://github.com/monperrus/crawler-user-agents) repo.<br>We use it from there anyway, so it will be included in our list as well. And it will help other people that use that repo as well.
- If you have bugfixes for my setup, other interesting examples, suggestions, ... you can create a issue or send a pull request here. Any contribution is welcome.

---

## License
This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.
