### About

Wrapper scripts for [Dokku](https://dokku.com/). Run once on your VPS, and a production ready
website will be running within 5 minutes, powered by Dokku.
Currently supports WordPress and Joomla, hopefully more apps soon.

### Installing

```
curl -fsSL https://raw.githubusercontent.com/belal-i/dokku-scrubs/develop/install.sh | bash
```

### Usage

The following examples should be self explanatory. They set up production ready WordPress
and Joomla sites respectively.

* ```
  dokku-scrubs --app wordpress --domain example.com --letsencrypt --email user@example.com
  ```
* ```
  dokku-scrubs --app joomla --domain example.com --letsencrypt --email user@example.com
  ```

### Known issues

It's not idempotent. So you just run the command once, and you're done. If you try to run it a second time,
extra containers get created, and other weird behavior. So just run it once, and if you have to
modify the runtime environment, [Dokku](https://dokku.com/) itself is actually quite excellent for that.
