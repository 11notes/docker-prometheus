${{ image: Graph.png }}

${{ content_synopsis }} This image will run Prometheus [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) and [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md), for maximum security and performance. You can either provide your own config file or configure Prometheus directly inline in your compose. If you run the compose example, you can open the following [URL](http://localhost:3000/query?g0.expr=histogram_quantile%280.9%2C+sum+by+%28le%29+%28rate%28dnspyre_dns_requests_duration_seconds_bucket%5B1m%5D%29%29%29&g0.show_tree=0&g0.tab=graph&g0.range_input=1m&g0.res_type=auto&g0.res_density=medium&g0.display_mode=lines&g0.show_exemplars=0) to see the statistics of your DNS benchmark just like in the screenshot.

${{ content_uvp }} Good question! Because ...

${{ github:> [!IMPORTANT] }}
${{ github:> }}* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
${{ github:> }}* ... this image has no shell since it is [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)
${{ github:> }}* ... this image is auto updated to the latest version via CI/CD
${{ github:> }}* ... this image has a health check
${{ github:> }}* ... this image runs read-only
${{ github:> }}* ... this image is automatically scanned for CVEs before and after publishing
${{ github:> }}* ... this image is created via a secure and pinned CI/CD process
${{ github:> }}* ... this image is very small
${{ github:> }}* ... this image supports [inline configs](https://github.com/11notes/RTFM/blob/master/linux/container/image/11notes/inline-config.md)

If you value security, simplicity and optimizations to the extreme, then this image might be for you.

${{ content_comparison }}

${{ title_config }}
```yaml
${{ include: ./rootfs/prometheus/etc/default.yml }}
```

${{ title_volumes }}
* **${{ json_root }}/etc** - Directory of your config
* **${{ json_root }}/var** - Directory of all dynamic data and database

${{ content_compose }}

${{ content_defaults }}

${{ content_environment }}
| `PROMETHEUS_CONFIG` *(optional)* | Will overwrite the default config with the value of this variable if set ([inline config](https://github.com/11notes/RTFM/blob/master/linux/container/image/11notes/inline-config.md)) | |

${{ content_source }}

${{ content_parent }}

${{ content_built }}

${{ content_tips }}