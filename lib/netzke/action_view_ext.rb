module Netzke
  module ActionViewExt
    # Include JavaScript
    def netzke_js_include
      # ExtJS
      res = ENV['RAILS_ENV'] == 'development' ? javascript_include_tag("/extjs/adapter/ext/ext-base.js", "/extjs/ext-all-debug.js") : javascript_include_tag("/extjs/adapter/ext/ext-base.js", "/extjs/ext-all.js")
      # Netzke (dynamically generated)
      res << javascript_include_tag("/netzke/netzke.js")
    end

    # Include CSS
    def netzke_css_include(theme_name = :default)
      # ExtJS base
      res = stylesheet_link_tag("/extjs/resources/css/ext-all.css")
      # ExtJS theming
      res << stylesheet_link_tag("/extjs/resources/css/xtheme-#{theme_name}.css") unless theme_name == :default
      # Netzke (dynamically generated)
      res << stylesheet_link_tag("/netzke/netzke.css")
      res
    end
    
    # JavaScript for all Netzke classes in this view, and Ext.onReady which renders all Netzke widgets in this view
    def netzke_js
      javascript_tag <<-END_OF_JAVASCRIPT
        Netzke.authenticityToken = '#{form_authenticity_token}'
        #{instance_variable_get("@content_for_netzke_js_classes")}
        Ext.onReady(function(){
          #{instance_variable_get("@content_for_netzke_on_ready")}
        });
      END_OF_JAVASCRIPT
    end
    
    # Wrapper for all the above. Use it in your layout.
    # Params: <tt>:ext_theme</tt> - the name of ExtJS theme to apply (optional)
    # E.g.:
    #   <%= netzke_init :ext_theme => "grey" %>
    def netzke_init(params = {})
      [netzke_css_include(params[:ext_theme]), netzke_js_include, netzke_js].join("\n")
    end
    
    # Use this helper in your views to embed Netzke widgets. E.g.:
    #   netzke :my_grid, :widget_class_name => "GridPanel", :columns => [:id, :name, :created_at]
    # On how to configure a widget, see documentation for Netzke::Base or/and specific widget
    def netzke(name, config = {})
      config[:widget_class_name] ||= name.to_s.classify
      config[:name] = name
      Netzke::Base.reg_widget(config)

      w = Netzke::Base.instance_by_config(config)
      content_for :netzke_js_classes, w.js_missing_code
      content_for :netzke_on_ready, w.js_widget_instance
      content_for :netzke_on_ready, w.js_widget_render
      w.js_widget_html
    end
  end
end

