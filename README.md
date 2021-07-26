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
----

SentinelGoblin is a file monitor that retrieves command outputs and
detects changes in them. Those changes can be useful to retrieve bad
modifications to configuration files, firewall rules, listening ports
or even checking on who's logged in.

Originally it was my fallback reference when trying out configs that I
~~knew were going to be messed up~~ was not that sure of. In advance I
can say that it won't keep you from locking yourself out of your server
(at least one of us already knows that), but at least you may find out
sooner the reason why.

----

**Disclaimer!**

1. This is a simple tool that I still use occasionally. It IS NOT a
fool proof way to ensure you are safe from making mistakes, on the contrary,
it may only help you (if set up properly) to find out what you did wrong.

2. This IS NOT a way to encourage bad practices in regard to production
environments. You should know better when making changes in production.
There are a lot of great virtualization applications for you to create
sandboxes instead of given it a go for real.
