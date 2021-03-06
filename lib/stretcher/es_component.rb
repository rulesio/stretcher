module Stretcher
  # Elasticsearch has symmetry across API endpoints for Server, Index, and Type, lets try and provide some common ground
  class EsComponent

    # Many of the methods marked protected are called by one line shims in subclasses. This is mostly to facilitate
    # better looking rdocs
    
    private
    
    def do_search(generic_opts={}, explicit_body=nil)
      query_opts = {}
      body = nil
      if explicit_body
        query_opts = generic_opts
        body = explicit_body
      else
        body = generic_opts
      end

      logger.info { "Stretcher Search: curl -XGET '#{Util.qurl(path_uri('_search'), query_opts)}' -d '#{body.to_json}'" }
      response = request(:get, "_search", query_opts) do |req|
        req.body = body
      end
      SearchResults.new(:raw => response)      
    end

    def do_refresh
      request(:post, "_refresh")
    end

    def request(method, path=nil, query_opts=nil, *args, &block)
      prefixed_path = path_uri(path)
      raise "Cannot issue request, no server specified!" unless @server
      @server.request(method, prefixed_path, query_opts, *args, &block)
    end
  end
end
