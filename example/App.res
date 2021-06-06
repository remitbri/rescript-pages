open Belt
include CssReset

module WidthContainer = {
  module Styles = {
    open Emotion
    let container = css({
      "width": "100%",
      "maxWidth": 1000,
      "marginLeft": "auto",
      "marginRight": "auto",
      "flexGrow": 1,
      "display": "flex",
      "flexDirection": "column",
    })
  }
  @react.component
  let make = (~children) => {
    <div className=Styles.container> children </div>
  }
}

module MarkdownBody = {
  module Styles = {
    open Emotion
    let text = css({
      "pre": {
        "padding": "10px 20px",
        "overflowX": "auto",
        "WebkitOverflowScrolling": "touch",
        "fontSize": 16,
        "borderRadius": 8,
      },
      "code": {
        "fontFamily": `SFMono-Regular, Consolas, "Liberation Mono", Menlo, Courier, monospace`,
        "fontSize": "0.85em",
        "lineHeight": 1.0,
      },
      "blockquote": {
        "opacity": 0.6,
        "borderLeft": `4px solid #333`,
        "margin": 0,
        "padding": "20px 0",
      },
    })
  }
  @react.component
  let make = (~body, ~additionalStyle=?) =>
    <div
      className={switch additionalStyle {
      | Some(additionalStyle) => Emotion.cx([Styles.text, additionalStyle])
      | None => Styles.text
      }}
      dangerouslySetInnerHTML={{"__html": body}}
    />
}

module FeatureBlock = {
  module Styles = {
    open Emotion
    let container = css({
      "padding": 20,
      "flexGrow": 1,
      "display": "flex",
      "flexDirection": "column",
    })
    let title = css({"fontSize": 18, "fontWeight": "normal", "fontWeight": "700"})
    let text = css({
      "fontSize": 14,
      "fontWeight": "normal",
      "flexGrow": 1,
      "display": "flex",
      "flexDirection": "column",
    })
    let additionalStyle = css({
      "flexGrow": 1,
      "display": "flex",
      "flexDirection": "column",
      "pre": {"flexGrow": 1},
    })
  }
  @react.component
  let make = (~title, ~text) => {
    <div className=Styles.container>
      <h2 className=Styles.title> {title->React.string} </h2>
      <div className=Styles.text>
        <MarkdownBody body=text additionalStyle=Styles.additionalStyle />
      </div>
    </div>
  }
}

module Home = {
  module Styles = {
    open Emotion
    let blocks = css({
      "display": "flex",
      "flexDirection": "row",
      "alignItems": "stretch",
      "flexWrap": "wrap",
      "@media (max-width: 600px)": {"flexDirection": "column"},
    })
    let title = css({
      "fontSize": 50,
      "textAlign": "center",
      "padding": "100px 0",
    })
    let block = css({
      "width": "33.3333%",
      "display": "flex",
      "flexDirection": "column",
      "@media (max-width: 600px)": {"width": "100%"},
    })
    let container = css({"flexGrow": 1})
  }
  @react.component
  let make = () => {
    let blocks = Pages.useCollection("features", ~direction=#asc)
    <div className=Styles.container>
      <WidthContainer>
        <div className=Styles.title> {"A dead-simple static website generator"->React.string} </div>
        <div className=Styles.blocks>
          {switch blocks {
          | NotAsked | Loading => <Pages.ActivityIndicator />
          | Done(Error(_)) => <Pages.ErrorIndicator />
          | Done(Ok({items})) =>
            items
            ->Array.map(block =>
              <div className=Styles.block key=block.slug>
                <FeatureBlock title=block.title text=block.summary />
              </div>
            )
            ->React.array
          }}
        </div>
      </WidthContainer>
    </div>
  }
}

module Docs = {
  module Styles = {
    open Emotion
    let container = css({
      "display": "flex",
      "flexDirection": "row",
      "alignItems": "flex-start",
      "flexGrow": 1,
      "position": "relative",
      "@media (max-width: 600px)": {"flexDirection": "column-reverse"},
    })
    let body = css({
      "width": 1,
      "flexGrow": 1,
      "flexShrink": 1,
      "display": "flex",
      "flexDirection": "column",
      "padding": 10,
      "boxSizing": "border-box",
      "@media (max-width: 600px)": {"width": "100%"},
    })
    let column = css({
      "width": 250,
      "boxSizing": "border-box",
      "padding": "20px 10px",
      "flexGrow": 0,
      "flexShrink": 0,
      "display": "flex",
      "flexDirection": "column",
      "position": "sticky",
      "top": 10,
    })
    let link = css({
      "color": "currentColor",
      "textDecoration": "none",
      "display": "block",
      "padding": 10,
    })
    let activeLink = css({"fontWeight": "bold"})
  }
  @react.component
  let make = (~slug) => {
    let item = Pages.useItem("docs", ~id=slug)
    let list = Pages.useCollection("docs", ~direction=#asc)
    <WidthContainer>
      <div className=Styles.container>
        <div className=Styles.column>
          {switch list {
          | NotAsked | Loading => <Pages.ActivityIndicator />
          | Done(Error(_)) => <Pages.ErrorIndicator />
          | Done(Ok({items})) => <>
              {items
              ->Array.map(item =>
                <Pages.Link
                  href={`/docs/${item.slug}`}
                  className=Styles.link
                  activeClassName=Styles.activeLink
                  key={item.slug}>
                  {item.title->React.string}
                </Pages.Link>
              )
              ->React.array}
            </>
          }}
        </div>
        <div className=Styles.body>
          {switch item {
          | NotAsked | Loading => <Pages.ActivityIndicator />
          | Done(Error(_)) => <Pages.ErrorIndicator />
          | Done(Ok(item)) => <>
              <h1> {item.title->React.string} </h1> <MarkdownBody body=item.body />
            </>
          }}
        </div>
      </div>
    </WidthContainer>
  }
}

module Spacer = {
  @react.component
  let make = (~width="10px", ~height="10px") =>
    <div style={ReactDOM.Style.make(~width, ~height, ~flexShrink="0", ~flexGrow="0", ())} />
}

module Header = {
  module Styles = {
    open Emotion
    let resetLink = css({"color": "currentColor", "textDecoration": "none"})
    let activeLink = css({"fontWeight": "bold"})
    let header = css({
      "paddingTop": 10,
      "paddingBottom": 10,
      "margin": 0,
      "backgroundColor": "rgba(0, 0, 0, 0.03)",
    })
    let headerContents = css({
      "display": "flex",
      "flexDirection": "row",
      "alignItems": "center",
      "justifyContent": "space-between",
      "flexWrap": "wrap",
      "paddingLeft": 10,
      "paddingRight": 10,
      "@media(max-width: 400px)": {
        "flexDirection": "column",
      },
    })
    let title = css({"fontSize": 18, "textAlign": "center"})
    let navigation = css({"display": "flex", "flexDirection": "row", "alignItems": "center"})
  }
  @react.component
  let make = () => {
    <div className=Styles.header>
      <WidthContainer>
        <div className=Styles.headerContents>
          <Pages.Link href="/" className=Styles.resetLink>
            <h1 className=Styles.title> {Pages.tr("ReScript Pages")} </h1>
          </Pages.Link>
          <Spacer width="100px" />
          <div className=Styles.navigation>
            <Pages.Link href="/" className=Styles.resetLink activeClassName=Styles.activeLink>
              {Pages.tr("Home")}
            </Pages.Link>
            <Spacer width="40px" />
            <Pages.Link
              href="/showcase" className=Styles.resetLink activeClassName=Styles.activeLink>
              {Pages.tr("Showcase")}
            </Pages.Link>
            <Spacer width="40px" />
            <Pages.Link
              href="/docs/getting-started"
              matchHref="/docs"
              className=Styles.resetLink
              activeClassName=Styles.activeLink
              matchSubroutes=true>
              {Pages.tr("Docs")}
            </Pages.Link>
            <Spacer width="40px" />
            <a href="https://github.com/bloodyowl/rescript-pages" className=Styles.resetLink>
              {Pages.tr("GitHub")}
            </a>
          </div>
        </div>
      </WidthContainer>
    </div>
  }
}

module Footer = {
  module Styles = {
    open Emotion
    let container = css({
      "backgroundColor": "#222",
      "color": "#fff",
      "textAlign": "center",
      "padding": 20,
      "fontSize": 14,
    })
  }

  @react.component
  let make = () => {
    <div className=Styles.container> {"Copyright 2020 - Matthias Le Brun"->React.string} </div>
  }
}

module ShowcaseWebsite = {
  module Styles = {
    open Emotion
    let container = css({
      "padding": 20,
      "flexGrow": 1,
      "display": "flex",
      "flexDirection": "column",
      "color": "inherit",
      "textDecoration": "none",
    })
    let title = css({
      "fontSize": 18,
      "fontWeight": "normal",
      "fontWeight": "700",
      "textAlign": "center",
    })
    let imageContainer = css({
      "overflow": "hidden",
      "position": "relative",
      "paddingBottom": {
        let ratio = 9.0 /. 16.0 *. 100.0
        `${ratio->Float.toString}%`
      },
      "borderRadius": 15,
      "boxShadow": "0 0 0 1px rgba(0, 0, 0, 0.1), 0 15px 20px rgba(0, 0, 0, 0.1)",
      "transform": "translateZ(0)",
    })
    let imageContents = css({
      "position": "absolute",
      "top": "-100%",
      "left": 0,
      "right": 0,
      "bottom": 0,
      "transition": "5000ms ease-out transform",
      "transform": "translateZ(0)",
      "@media (hover: hover)": {
        ":hover": {
          "transform": "translateZ(0) translateY(50%)",
        },
      },
    })
    let image = css({
      "position": "absolute",
      "top": "50%",
      "left": 0,
      "width": "100%",
      "height": "auto",
      "transition": "300ms ease-out opacity, 5000ms ease-out transform",
      "opacity": 0.0,
      "transform": "translateZ(0)",
      "@media (hover: hover)": {
        ":hover": {
          "transform": "translateZ(0) translateY(-100%)",
        },
      },
    })
    let loadedImage = cx([image, css({"opacity": 1.0})])
  }

  external elementAsObject: Dom.element => {..} = "%identity"

  @react.component
  let make = (~title, ~url, ~image) => {
    let imageRef = React.useRef(Js.Nullable.null)
    let (isImageLoaded, setIsImageLoaded) = React.useState(() => false)

    React.useEffect0(() => {
      switch imageRef.current->Js.Nullable.toOption {
      | Some(image) if (image->elementAsObject)["complete"] => setIsImageLoaded(_ => true)
      | _ => ()
      }
      None
    })

    <a href=url className=Styles.container target="_blank">
      <h2 className=Styles.title> {title->React.string} </h2>
      <div className=Styles.imageContainer>
        <div className=Styles.imageContents>
          <img
            ref={ReactDOM.Ref.domRef(imageRef)}
            className={isImageLoaded ? Styles.loadedImage : Styles.image}
            onLoad={_ => setIsImageLoaded(_ => true)}
            alt=""
            src=image
          />
        </div>
      </div>
    </a>
  }
}

module Showcase = {
  module Styles = {
    open Emotion
    let container = css({
      "display": "flex",
      "flexDirection": "column",
      "flexGrow": 1,
    })
    let title = css({
      "fontSize": 40,
      "textAlign": "center",
      "padding": "30px 0",
    })
    let blocks = css({
      "display": "flex",
      "flexDirection": "row",
      "alignItems": "stretch",
      "flexWrap": "wrap",
      "@media (max-width: 600px)": {"flexDirection": "column"},
    })
    let block = css({
      "width": "50%",
      "display": "flex",
      "flexDirection": "column",
      "@media (max-width: 600px)": {"width": "100%"},
    })
  }

  @react.component
  let make = () => {
    <WidthContainer>
      <div className=Styles.container>
        <div className=Styles.title> {"Showcase"->React.string} </div>
        <div className=Styles.blocks>
          {ShowcaseWebsiteList.websites
          ->Array.map(website => {
            <div key=website.url className=Styles.block>
              <ShowcaseWebsite title=website.title url=website.url image=website.image />
            </div>
          })
          ->React.array}
        </div>
      </div>
    </WidthContainer>
  }
}

module App = {
  module Styles = {
    open Emotion
    let container = css({"display": "flex", "flexDirection": "column", "flexGrow": 1})
  }
  @react.component
  let make = (~url as {RescriptReactRouter.path: path}, ~config as _) => {
    <div className=Styles.container>
      <Pages.Head>
        <meta content="width=device-width, initial-scale=1, shrink-to-fit=no" name="viewport" />
        <style> {"html { font-family: sans-serif }"->React.string} </style>
      </Pages.Head>
      <Header />
      {switch path {
      | list{} => <> <Home /> </>
      | list{"showcase"} => <> <Showcase /> </>
      | list{"docs", slug} => <> <Docs slug /> </>
      | list{"404.html"} => <div> {"Page not found..."->React.string} </div>
      | _ => <div> {"Page not found..."->React.string} </div>
      }}
      <Footer />
    </div>
  }
}

let getUrlsToPrerender = ({Pages.getAll: getAll}) =>
  Array.concatMany([
    ["/", "showcase"],
    getAll("docs")->Array.map(slug => `/docs/${slug}`),
    ["404.html"],
  ])

let default = Pages.make(
  App.make,
  {
    siteTitle: "ReScript Pages",
    mode: SPA,
    siteDescription: "A static website generator",
    distDirectory: "dist",
    baseUrl: "https://bloodyowl.github.io/rescript-pages",
    staticsDirectory: Some("statics"),
    paginateBy: 2,
    variants: [
      {
        subdirectory: None,
        localeFile: None,
        contentDirectory: "contents",
        getUrlsToPrerender: getUrlsToPrerender,
        getRedirectMap: Some(
          _ => {
            Js.Dict.fromArray([("old_url", "new_url")])
          },
        ),
      },
    ],
  },
)
