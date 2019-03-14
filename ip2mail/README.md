# ip2mail
Install `mutt` using your package manager:
```
$ sudo apt install mutt
```

Copy the example configurations:

```
$ cp .env.example .env
$ cp .muttrc.example .muttrc
```

Open `.env` and set `DEVICE_NAME` and `RECIPIENT`.

Open `.muttrc` and set `my_address` and `smtp_pass`. This is the sender email, and it should be a Gmail account.

You can now set up a cronjob that periodically runs `bash get_ip.sh` to check if the local ip has changed, in which case an email will be sent to `RECIPIENT`.
