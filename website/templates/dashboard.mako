<%inherit file="base.mako"/>
<%def name="title()">Dashboard</%def>

<%def name="stylesheets()">
<link rel="stylesheet" href="/static/css/typeahead.css">
<link rel="stylesheet" href="/static/css/onboarding.css">
</%def>

<%def name="content()">
<div class="row">
    <div class="col-md-7">
        <div class="project-details"></div>
        <div class="page-header">
            <div class="pull-right"><a class="btn btn-default" href="/folder/${dashboard_id}" id = "${dashboard_id}">New Folder</a></div>
            <h3>Projects</h3>
        </div><!-- end .page-header -->
        <link rel="stylesheet" href="/static/css/projectorganizer.css">
        % if seen_dashboard == False:
            <div class="alert alert-info">The OSF has a new dashboard. Find out how it works on our <a href="/getting-started/#dashboards">getting started</a> page.</div>
        % endif

        <div class="project-organizer" id="projectOrganizerScope">
            <%include file="projectGridTemplates.html"/>

            <div class="hgrid" id="project-grid"></div>
            <span class = 'organizer-legend'><img src="/static/img/hgrid/folder.png">Folder</span>
            <span class = 'organizer-legend'><img src="/static/img/hgrid/smart-folder.png">Smart Folder</span>
            <span class = 'organizer-legend'><img src="/static/img/hgrid/project.png">Project</span>
            <span class = 'organizer-legend'><img src="/static/img/hgrid/reg-project.png">Registration</span>
            <span class = 'organizer-legend'><img src="/static/img/hgrid/component.png">Component</span>
            <span class = 'organizer-legend'><img src="/static/img/hgrid/reg-component.png">Registered Component</span>
            <span class = 'organizer-legend'><img src="/static/img/hgrid/pointer.png">Link</span>
        </div><!-- end project-organizer -->
    </div> <!-- end col-md -->

    <%include file='_log_templates.mako'/>
    ## Knockout componenet templates
    <%include file="components/dashboard_templates.mako"/>
    <div class="col-md-5">
        <div class="ob-tab-head" id="obTabHead">
            <ul class="nav nav-tabs" role="tablist">
            <li class="active"><a href="#quicktasks" role="tab" data-toggle="tab">Quick Tasks</a></li>
            <li><a href="#watchlist" role="tab" data-toggle="tab">Watchlist</a></li>
            ## %if 'badges' in addons_enabled:
            ## <li><a href="#badges" role="tab" data-toggle="tab">Badges</a></li>
            ## %endif
            </ul>

        </div><!-- end #obTabHead -->
        <div class="tab-content" >
            <div class="tab-pane active" id="quicktasks">
                <ul class="ob-widget-list"> <!-- start onboarding -->
                    ## <%include file="ob_new_project.mako"/>
                    <div id="projectCreate">
                        <li id="obNewProject" class="ob-list-item list-group-item">

                            <div data-bind="click: toggle" class="ob-header pointer">
                                <h3
                                    class="ob-heading list-group-item-heading">
                                    Create a project
                                </h3>
                                <i data-bind="css: {'icon-plus': !isOpen(), 'icon-minus': isOpen()}"
                                    class="pointer ob-expand-icon icon-large pull-right">
                                </i>
                            </div><!-- end ob-header -->
                            <div data-bind="visible: isOpen()" id="obRevealNewProject">
                                <project-create-form params="data: nodes">
                                </project-create-form>
                            </div>
                        </li> <!-- end ob-list-item -->
                    </div>
                    <div id="obRegisterProject">
                        <osf-ob-register params="data: nodes"></osf-ob-register>
                    </div>
                    <div id="obUploader">
                        <osf-ob-uploader params="data: nodes"></osf-ob-uploader>
                    </div>
                </ul> <!-- end onboarding -->
            </div><!-- end .tab-pane -->
            <div class="tab-pane" id="watchlist">
                <%include file="log_list.mako" args="scripted=False"/>
            </div><!-- end tab-pane -->
            ## %if 'badges' in addons_enabled:
                ## <%include file="dashboard_badges.mako"/>
            ## %endif
        </div><!-- end .tab-content -->
    </div><!-- end col-md -->
</div><!-- end row -->
%if 'badges' in addons_enabled:
    <div class="row">
        <div class="col-md-5">
            <div class="page-header">
              <button class="btn btn-success pull-right" id="newBadge" type="button">New Badge</button>
                <h3>Your Badges</h3>
            </div>
            <div mod-meta='{
                     "tpl": "../addons/badges/templates/dashboard_badges.mako",
                     "uri": "/api/v1/dashboard/get_badges/",
                     "replace": true
                }'></div>
        </div><!-- end col-md -->
        <div class="col-md-5">
            <div class="page-header">
                <h3>Badges You've Awarded</h3>
            </div>
        </div><!-- end col-md-->
    </div><!-- end row -->
%endif
</div>
</%def>

<%def name="javascript_bottom()">

<script>
    $script(['/static/js/onboarder.js']);  // exports onboarder
    $script(['/static/js/projectCreator.js']);  // exports projectCreator

    $script.ready(['projectCreator', 'onboarder'], function() {
        // Send a single request to get the data to populate the typeaheads
        var url = "${api_url_for('get_dashboard_nodes', no_components=True)}";
        var request = $.getJSON(url, function(response) {
            $.osf.applyBindings({nodes: response.nodes }, '#obRegisterProject');
            $.osf.applyBindings({nodes: response.nodes }, '#obUploader');
            $.osf.applyBindings({
                isOpen: ko.observable(false),
                open: function() {
                    this.isOpen(true);
                },
                close: function() {
                    this.isOpen(false);
                },
                toggle: function() {
                    if (!this.isOpen()) {
                        this.open();
                    } else {
                        this.close();
                    }
                },
                nodes: response.nodes
            }, '#projectCreate');
        });
        request.fail(function(xhr, textStatus, error) {
            Raven.captureMessage('Could not fetch dashboard nodes.', {
                url: url, textStatus: textStatus, error: error
            });
        });
    });

     // initialize the logfeed
    $script(['/static/js/logFeed.js']);
    $script.ready('logFeed', function() {
        // NOTE: the div#logScope comes from log_list.mako
        var logFeed = new LogFeed("#logScope", "/api/v1/watched/logs/");
    });
</script>

##       Project Organizer
    <script src="/static/vendor/jquery-drag-drop/jquery.event.drag-2.2.js"></script>
    <script src="/static/vendor/jquery-drag-drop/jquery.event.drop-2.2.js"></script>
    <script>
        $script.ready(['hgrid'], function() {
            $script(['/static/vendor/bower_components/hgrid/plugins/hgrid-draggable/hgrid-draggable.js'],'hgrid-draggable');
        });
        $script(['/static/js/handlebars-v1.3.0.js'],'handlebars');
        $script(['/static/js/projectorganizer.js']);
        $script.ready(['projectorganizer'], function() {
            var projectbrowser = new ProjectOrganizer('#project-grid');
        });
    </script>
</%def>
