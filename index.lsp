<?lsp

local session=request:session(true)

local get = request:data()

?>

    <!DOCTYPE html>
    <html lang="zh-CN">

    <head>
        <!-- 设置文档编码和视口 -->
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>主页 | MeowPayment</title>
        <!-- 引入 Bootstrap CSS -->
        <link href="/css/bootstrap.min.css" rel="stylesheet">
        <link href="/css/bootstrap-icons.min.css" rel="stylesheet">
        <!-- 引入 htmx JS -->
        <script src="/js/htmx.min.js"></script>
        <!-- 引入 highlight.js CSS -->
        <link rel="stylesheet" href="/css/highlight.js/monokai-sublime.css">
        <!-- 引入 highlight.js JS -->
        <script src="/js/highlight.min.js"></script>
        <!-- 引入自定义样式 -->
        <link href="/css/meowdream-better-links.css" rel="stylesheet">
        <link href="/css/meowdream-colors.css" rel="stylesheet">
        <link href="/css/meowdream-custom.css" rel="stylesheet">
        <script src="/js/meowdream-fetch-fix.js"></script>
        <style>
            /* 自定义样式 */
            
            .roundButton {
                width: 40px;
                height: 40px;
                background-color: var(--gray-500);
                position: fixed;
                border: none;
                cursor: pointer;
                outline: none;
                padding: 0px;
                box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.4);
            }
            
            #openListButton {
                bottom: 32px;
                right: 32px;
            }
            
            #scrollTopButton {
                bottom: 90px;
                right: 32px;
                background-color: var(--gray-500);
                opacity: 0;
                transition: opacity 0.3s ease-in-out;
            }
            
            #homeButton {
                bottom: 32px;
                right: 90px;
            }
            
            #openListButton:hover {
                background-color: #424242;
            }
            
            #scrollTopButton:hover {
                background-color: #424242;
            }
            
            #homeButton:hover {
                background-color: #424242;
            }
            
            #scrollTopButton.show {
                opacity: 1;
            }
        </style>
    </head>

    <body>
        <!-- 页面内容 -->
        <div class="container py-4">
            <div class="row my-5">
                <h1>主页</h1>
                <!-- 标题 -->
            </div>
            <hr class="divider">
            <!-- 分隔线 -->
            <div class="row mt-4">
                <!-- 左侧目录 -->
                <div class="offcanvas offcanvas-start" tabindex="-1" id="listOffcanvas" aria-labelledby="listOffcanvasLabel">
                    <div class="offcanvas-header">
                        <h5 class="offcanvas-title" id="offcanvasExampleLabel">菜单</h5>
                        <button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
                    </div>
                    <div class="scrollable-content-problem mb-0 offcanvas-body" style="overflow-y: auto;">
                        <div id="left-list" class="nav nav-pills flex-column"></div>
                    </div>
                </div>
                <!-- 文档内容区域 -->
                <div class="col">
                    <div class="scrollable-content-problem mb-0" style="overflow-y: auto;">
                        <div id="document-content" class="px-3">
                            <!-- 文档内容将动态加载到这里 -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- 操作按钮 -->
        <button id="openListButton" class="roundButton rounded-circle btn" type="button" data-bs-toggle="offcanvas" data-bs-target="#listOffcanvas" aria-controls="listOffcanvas"><i class="bi-list" style="color: white;"></i></button>
        <button id="scrollTopButton" class="roundButton rounded-circle btn" type="button" onclick="scrollToTop()"><i class="bi-arrow-bar-up" style="color: white;"></i></button>
        <button id="homeButton" class="roundButton rounded-circle btn" type="button" onclick="window.location.href = '/';"><i class="bi-house" style="color: white;"></i></button>
        <!-- 引入 Bootstrap JS -->
        <script src="/js/bootstrap.bundle.min.js"></script>
        <!-- 引入 marked JS -->
        <script src="/js/marked.min.js"></script>
        <!-- 引入自定义 Markdown 渲染器 -->
        <script src="/js/meowdream-custom-md-renderer.js"></script>
        <script>
            // 滚动事件
            window.onscroll = function() {
                scrollFunction();
            };

            // 判断滚动位置，显示/隐藏“返回顶部”按钮
            function scrollFunction() {
                var scrollTopButton = document.getElementById("scrollTopButton");
                if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
                    scrollTopButton.classList.add("show");
                } else {
                    scrollTopButton.classList.remove("show");
                }
            }

            // 返回顶部函数
            function scrollToTop() {
                document.body.scrollTop = 0; // Safari
                document.documentElement.scrollTop = 0; // Chrome, Firefox, IE, Opera
            }

            // 解析列表函数
            function parseList() {
                <?lsp 
                list_file = ''
                if (not get.action) and session.access_token then
                    list_file = '/list.txt'
                else
                    list_file = '/list-nologin.txt'
                end
                ?>
                fetch("<?lsp=list_file?>")
                    .then(response => response.text())
                    .then(data => {
                        const lines = data.split("\n");
                        const listContainer = document.getElementById("left-list");
                        listContainer.innerHTML = ""; // 清空容器

                        let countPlus = 0; // 用于跟踪+的数量
                        let textBuffer = ""; // 用于暂存文本
                        lines.forEach(line => {
                            line = line.trim(); // 去除首尾空白字符
                            if (line === "") {
                                return; // 忽略空行
                            }
                            if (/^={3,}$|^-{3,}$/.test(line)) {
                                // 渲染为分隔线
                                const divider = document.createElement("hr");
                                divider.classList.add("divider");
                                listContainer.appendChild(divider);
                            } else if (/^\+{1,3}(.*?)$/.test(line)) {
                                countPlus = line.match(/\+/g).length;
                                textBuffer = line.replace(/^\+{1,3}/, "").trim();
                                // 渲染为标题
                                if (countPlus > 0) {
                                    const listItem = document.createElement("li");
                                    listItem.classList.add("nav-item", "leftList-title");
                                    const link = document.createElement("a");
                                    link.classList.add("nav-link", "disabled");
                                    link.style.fontSize = countPlus === 1 ? "larger" : countPlus === 2 ? "x-large" : "xx-large";
                                    link.href = "#";
                                    link.textContent = textBuffer.trim();
                                    listItem.appendChild(link);
                                    listContainer.appendChild(listItem);
                                }
                                // 重置计数器和文本缓冲
                            } else if (/^\((.*?)\)\[(.*?)\]$/.test(line)) {
                                // 渲染为带链接的列表项
                                const match = line.match(/^\((.*?)\)\[(.*?)\]$/);
                                const text = match[1];
                                const link = match[2];
                                const listItem = document.createElement("li");
                                listItem.classList.add("nav-item", "leftList-link");
                                listItem.id = link;
                                listItem.onclick = function() {
                                    window.location.href = this.id;
                                };
                                const anchor = document.createElement("a");
                                anchor.classList.add("nav-link");
                                anchor.href = "#";
                                anchor.textContent = text;
                                listItem.appendChild(anchor);
                                listContainer.appendChild(listItem);
                            } else {
                                // 默认情况渲染为普通列表项
                                const listItem = document.createElement("li");
                                listItem.classList.add("nav-item");
                                const anchor = document.createElement("a");
                                anchor.classList.add("nav-link", "disabled");
                                anchor.href = "#";
                                anchor.textContent = line.trim();
                                listItem.appendChild(anchor);
                                listContainer.appendChild(listItem);
                            }
                        });
                    })
                    .catch(error => {
                        console.error('Error fetching or parsing data:', error);
                    });
                }

                // 调用解析目录函数
                parseList();

                // 使用自定义 Markdown 渲染器
                marked.use({
                    renderer: customRenderer
                });

                // 加载 Markdown 文档并渲染
                function loadMarkdown(url) {
                    fetch(url)
                        .then(response => {
                            if (response.ok) {
                                // 返回一个 Promise，等待响应的文本
                                return response.text();
                            } else {
                                // 如果响应不ok，返回一个包含404错误信息的Promise
                                return Promise.reject('Error 404 NOT FOUND');
                            }
                        })
                        .then(markdownText => {
                            // 将Markdown文本转换为HTML
                            var html = marked.parse(markdownText);
                            // 将HTML渲染到document-content区域
                            document.getElementById('document-content').innerHTML = html;
                            hljs.highlightAll();
                            scrollToTop();
                        })
                        .catch(error => {
                            console.error('Error loading Markdown document:', error);
                            // 如果发生错误，渲染404错误信息
                            var html = marked.parse("# Error 404 NOT FOUND\n**您要找的页面似乎被猫猫叼走了呢...**\n\n[返回主页](InPage:/docs/welcome.md)\n\n<br />\n\n## POWERED BY\n![pic](/image/logo-title.png)");
                            document.getElementById('document-content').innerHTML = html;
                        });
                }

                // 更新scrollable-content的高度，使其底部始终与窗口底部保持50px距离
                function updateScrollableContentHeight() {
                    const windowHeight = window.innerHeight;
                    document.querySelectorAll('.scrollable-content').forEach(function(element) {
                        const newHeight = windowHeight - element.offsetTop - 25;
                        element.style.height = `${newHeight}px`;
                    });
                }

                // 当窗口大小发生变化时更新scrollable-content的高度
                window.addEventListener('resize', updateScrollableContentHeight);

                // 当 DOM 加载完成时执行
                document.addEventListener("DOMContentLoaded", function(event) {
                    
                        loadMarkdown("/index.md");
                    
                    // 初始更新scrollable-content的高度
                    updateScrollableContentHeight();
                });
        </script>

        <script src="/js/meowdream-utils.js"></script>
    </body>

    </html>