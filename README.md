```
 ███████╗███████╗███╗   ██╗████████╗██╗███╗   ██╗███████╗██╗     
 ██╔════╝██╔════╝████╗  ██║╚══██╔══╝██║████╗  ██║██╔════╝██║     
 ███████╗█████╗  ██╔██╗ ██║   ██║   ██║██╔██╗ ██║█████╗  ██║     
 ╚════██║██╔══╝  ██║╚██╗██║   ██║   ██║██║╚██╗██║██╔══╝  ██║     
 ███████║███████╗██║ ╚████║   ██║   ██║██║ ╚████║███████╗███████╗
 ╚══════╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝
          ██████╗  ██████╗ ██████╗ ██╗     ██╗███╗   ██╗         
         ██╔════╝ ██╔═══██╗██╔══██╗██║     ██║████╗  ██║         
         ██║  ███╗██║   ██║██████╔╝██║     ██║██╔██╗ ██║         
         ██║   ██║██║   ██║██╔══██╗██║     ██║██║╚██╗██║         
         ╚██████╔╝╚██████╔╝██████╔╝███████╗██║██║ ╚████║         
          ╚═════╝  ╚═════╝ ╚═════╝ ╚══════╝╚═╝╚═╝  ╚═══╝         
                                                           v1.1.0
```

## DESCRIPTION

SentinelGoblin is a file monitor that retrieves command outputs and
detects changes in them. Those changes can be useful when fixing bad
modifications to configuration files, firewall rules, listening ports
or even checking on who's loggin in.

Originally it was my fallback reference when trying out configs that I
~~knew were going to be messed up~~ was not that sure of. In advance I
can say that it won't keep you from locking yourself out of your server
(at least one of us already knows that), but at least you may find out
sooner the reason why.

PS. enabling timestamps on your bash history helps a lot too

----

**Disclaimer!**

1. This is a simple tool that I still use occasionally. It IS NOT a
fool proof way to ensure you are safe from making mistakes, on the contrary,
it may only help you (if set up properly) to find out what you did wrong.

2. This IS NOT a way to encourage bad practices in regard to production
environments. You should know better when making changes in production.
There are a lot of great virtualization applications for you to create
sandboxes instead of given it a go for real.

----

#### DEPENDENCIES

Something as simple as `<your_package_manager_here> install <package>` should take care of it!

- curl

----

#### INSTALLATION & USAGE

The basic steps to set up sentinelGoblin are as follows:

```bash
clone https://github.com/leandroschabarum/sentinelGoblin.git

cd sentinelGoblin
sudo bash setupSG.sh
```

Now you can make changes to your configuration file at `/opt/sentinelGoblin/gold.conf`
to enable Telegram notifications (curl required).

When that is done, sentinelGoblin service is ready to be started.

```bash
sudo systemctl start sentinelGoblin
sudo systemctl enable sentinelGoblin
```

That's it! SentinelGoblin should be running and enabled at boot.
