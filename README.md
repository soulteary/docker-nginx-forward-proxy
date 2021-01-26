# Docker Nginx Forward Proxy

Perhaps the smallest nginx forward proxy server docker images.

For Centrally manage application export traffic, A/B testing, etc.

## Usage

start nginx server first:

```bash
docker run --rm -d -p 8080:80 soulteary/docker-nginx-forward-proxy
```

Refer to the post for setting environment variables:

- [Set a network range in the no_proxy environment variable](https://unix.stackexchange.com/questions/23452/set-a-network-range-in-the-no-proxy-environment-variable)

For docker users, you can edit the **docker.service** file:

`/lib/systemd/system/docker.service`

```bash
Environment="HTTP_PROXY=http://YOUR_NGX_PROXY_SERVER:8080/" "HTTPS_PROXY=https://YOUR_NGX_PROXY_SERVER:8080/"
```

## Security

It is not recommended to use any authentication method like "Basic Auth", waste server resources.

A better approach is to use a cloud service provider or our own firewall, and deploy the service on the application intranet.

Reduce the possibility that the service can be accessed instead of simply adding a lock that is not too secure.

## Test

Test `http://domain.ltd` :

```bash
curl --proxy http://localhost:8080 http://www.baidu.com --include --verbose
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8080 (#0)
> GET http://www.baidu.com/ HTTP/1.1
> Host: www.baidu.com
> User-Agent: curl/7.64.1
> Accept: */*
> Proxy-Connection: Keep-Alive
> 

< HTTP/1.1 200 OK
HTTP/1.1 200 OK
< Server: nginx
Server: nginx
< Date: Tue, 26 Jan 2021 16:08:20 GMT
Date: Tue, 26 Jan 2021 16:08:20 GMT
< Content-Type: text/html
Content-Type: text/html
< Content-Length: 2381
Content-Length: 2381
< Connection: keep-alive
Connection: keep-alive
< Accept-Ranges: bytes
Accept-Ranges: bytes
< Cache-Control: private, no-cache, no-store, proxy-revalidate, no-transform
Cache-Control: private, no-cache, no-store, proxy-revalidate, no-transform
< Etag: "588604ec-94d"
Etag: "588604ec-94d"
< Last-Modified: Mon, 23 Jan 2017 13:28:12 GMT
Last-Modified: Mon, 23 Jan 2017 13:28:12 GMT
< Pragma: no-cache
Pragma: no-cache
< Set-Cookie: BDORZ=27315; max-age=86400; domain=.baidu.com; path=/
Set-Cookie: BDORZ=27315; max-age=86400; domain=.baidu.com; path=/

< 
<!DOCTYPE html>
....
```

Test `http://domain.ltd` with https redirect:

```bash
curl --proxy http://localhost:8080 http://www.alibaba.com --include --verbose

*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8080 (#0)
> GET http://www.alibaba.com/ HTTP/1.1
> Host: www.alibaba.com
> User-Agent: curl/7.64.1
> Accept: */*
> Proxy-Connection: Keep-Alive
> 
< HTTP/1.1 301 Moved Permanently
HTTP/1.1 301 Moved Permanently
< Server: nginx
Server: nginx
< Date: Tue, 26 Jan 2021 16:09:07 GMT
Date: Tue, 26 Jan 2021 16:09:07 GMT
< Content-Type: text/html
Content-Type: text/html
< Content-Length: 239
Content-Length: 239
< Connection: keep-alive
Connection: keep-alive
< Location: https://www.alibaba.com/
Location: https://www.alibaba.com/
< Timing-Allow-Origin: *
Timing-Allow-Origin: *
< EagleId: 0bb1292216116773475272349ef29f
EagleId: 0bb1292216116773475272349ef29f
< server-timing: rt;dur=0.000,eagleid;desc=0bb1292216116773475272349ef29f
server-timing: rt;dur=0.000,eagleid;desc=0bb1292216116773475272349ef29f

< 
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html>
<head><title>301 Moved Permanently</title></head>
<body>
<center><h1>301 Moved Permanently</h1></center>
<hr/>Powered by Tengine<hr><center>tengine</center>
</body>
</html>
* Connection #0 to host localhost left intact
* Closing connection 0
```

Test `https://domain.ltd`:

```bash
 curl --proxy http://localhost:8080 https://www.tencent.com --include --verbose

*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8080 (#0)
* allocate connect buffer!
* Establish HTTP proxy tunnel to www.tencent.com:443
> CONNECT www.tencent.com:443 HTTP/1.1
> Host: www.tencent.com:443
> User-Agent: curl/7.64.1
> Proxy-Connection: Keep-Alive
> 
< HTTP/1.1 200 Connection Established
HTTP/1.1 200 Connection Established
< Proxy-agent: nginx
Proxy-agent: nginx
< 

* Proxy replied 200 to CONNECT request
* CONNECT phase completed!
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/cert.pem
  CApath: none
* TLSv1.2 (OUT), TLS handshake, Client hello (1):
* CONNECT phase completed!
* CONNECT phase completed!
* TLSv1.2 (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS handshake, Certificate (11):
* TLSv1.2 (IN), TLS handshake, Server key exchange (12):
* TLSv1.2 (IN), TLS handshake, Server finished (14):
* TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
* TLSv1.2 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (OUT), TLS handshake, Finished (20):
* TLSv1.2 (IN), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (IN), TLS handshake, Finished (20):
* SSL connection using TLSv1.2 / ECDHE-RSA-AES128-GCM-SHA256
* ALPN, server accepted to use h2
* Server certificate:
*  subject: C=CN; ST=Guangdong Province; L=Shenzhen; O=Shenzhen Tencent Computer Systems Company Limited; OU=R&D; CN=tencent.com
*  start date: Apr 24 00:00:00 2020 GMT
*  expire date: Jun 20 12:00:00 2021 GMT
*  subjectAltName: host "www.tencent.com" matched cert's "www.tencent.com"
*  issuer: C=US; O=DigiCert Inc; OU=www.digicert.com; CN=Secure Site CA G2
*  SSL certificate verify ok.
* Using HTTP2, server supports multi-use
* Connection state changed (HTTP/2 confirmed)
* Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
* Using Stream ID: 1 (easy handle 0x7fc1c700e800)
> GET / HTTP/2
> Host: www.tencent.com
> User-Agent: curl/7.64.1
> Accept: */*
> 
* Connection state changed (MAX_CONCURRENT_STREAMS == 128)!
< HTTP/2 200 
HTTP/2 200 
< date: Tue, 26 Jan 2021 16:09:59 GMT
date: Tue, 26 Jan 2021 16:09:59 GMT
< content-type: text/html; charset=UTF-8
content-type: text/html; charset=UTF-8
< content-length: 32744
content-length: 32744
< server: nginx
server: nginx
< cache-control: private, max-age=600
cache-control: private, max-age=600
< expires: Tue, 26 Jan 2021 16:19:59 GMT
expires: Tue, 26 Jan 2021 16:19:59 GMT
< last-modified: Tue, 26 Jan 2021 16:00:00 GMT
last-modified: Tue, 26 Jan 2021 16:00:00 GMT
< x-verify-code: 01f3329c249d6407ff4c4156c7a6313e
x-verify-code: 01f3329c249d6407ff4c4156c7a6313e
< x-nws-uuid-verify: 3eb6a9e6eca0f2aed35c510a517e572d
x-nws-uuid-verify: 3eb6a9e6eca0f2aed35c510a517e572d
< x-xss-protection: 0
x-xss-protection: 0
< x-nws-log-uuid: 6a6d09e3-0577-44a8-9878-13e56eeff188
x-nws-log-uuid: 6a6d09e3-0577-44a8-9878-13e56eeff188
< x-cache-lookup: Hit From Upstream
x-cache-lookup: Hit From Upstream
< x-cache-lookup: Hit From Upstream
x-cache-lookup: Hit From Upstream
< x-daa-tunnel: hop_count=1
x-daa-tunnel: hop_count=1
< x-cache-lookup: Hit From Upstream
x-cache-lookup: Hit From Upstream

< 
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
...
```

## Resource

- [chobits/ngx_http_proxy_connect_module](https://github.com/chobits/ngx_http_proxy_connect_module)
    - Nginx HTTP Proxy Connect Module Project, used by Tengine.
- [DockerHub Repo](https://hub.docker.com/r/soulteary/docker-nginx-forward-proxy)
    - Build image of this project base Nginx Offical Images.
- [hinata/nginx-forward-proxy](https://github.com/hinata/nginx-forward-proxy)
    - Thanks for pointing out the specified proxy client version.
