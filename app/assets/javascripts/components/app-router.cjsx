React = require("react")
App         = require './app'
Router      = require 'react-router'
{Handler, Root, RouteHandler, Route, DefaultRoute, Navigation, Link} = Router

HomePage                      = require './home-page'
Mark                          = require './mark'
Transcribe                    = require './transcribe'
Verify                        = require './verify'

# TODO Group routes currently not implemented
GroupPage                     = require './group-page'
GroupBrowser                  = require './group-browser'

class AppRouter
  constructor: ->
    API.type('projects').get().then (result)=>
      @runRoutes result[0]

  runRoutes: (project) ->
    routes =
      <Route name="root" path="/" handler={App}>

        <Route name="home" path="/home" handler={HomePage} />

        { (w for w in project.workflows when w.name in ['mark','transcribe','verify']).map (workflow, key) =>
            handler = eval workflow.name.charAt(0).toUpperCase() + workflow.name.slice(1)
            <Route
              key={key}
              path={workflow.name}
              handler={handler}
              name={workflow.name}
            />
        }

        { (w for w, i in project.workflows when w.name in ['mark']).map (workflow, key) =>
            handler = eval workflow.name.charAt(0).toUpperCase() + workflow.name.slice(1)
            <Route
              key={key}
              path={workflow.name + '/:subject_set_id' + '/:subject_id'}
              handler={handler}
              name={workflow.name + '_specific_subject'}
            />
        }
        { (w for w, i in project.workflows when w.name in ['mark']).map (workflow, key) =>
            handler = eval workflow.name.charAt(0).toUpperCase() + workflow.name.slice(1)
            <Route
              key={key}
              path={workflow.name + '/:subject_set_id'}
              handler={handler}
              name={workflow.name + '_specific_set'}
            />
        }
        { (w for w, i in project.workflows when w.name in ['transcribe','verify']).map (workflow, key) =>
            handler = eval workflow.name.charAt(0).toUpperCase() + workflow.name.slice(1)
            <Route
              key={key}
              path={workflow.name + '/:subject_id' }
              handler={handler}
              name={workflow.name + '_specific'}
            />
        }

        { # Project-configured pages:
          project.pages?.map (page, key) =>
            <Route
              key={key}
              path={page.name}
              handler={@controllerForPage(page)}
              name={page.name}
            />
        }

        <Route
          path='groups'
          handler={GroupBrowser}
          name='groups'
        />
        <Route
          path='groups/:group_id'
          handler={GroupPage}
          name='group_show'
        />


        <DefaultRoute name="home-default" handler={HomePage} />
      </Route>

    Router.run routes, (Handler) ->
      React.render <Handler />, document.body

  controllerForPage: (page) ->
    React.createClass
      displayName: "#{page.name}Page"
      render: ->
        <div className="page-content">
          <h1>{page.name}</h1>
          <div dangerouslySetInnerHTML={{__html: page.content}} />
        </div>

module.exports = AppRouter
window.React = React
