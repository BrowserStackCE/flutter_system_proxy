function FindProxyForURL(url, host)
{
    if(host.includes("ip-api")){
     return "PROXY 127.0.0.1:8000"
    }else{
        return "DIRECT"
    }
}