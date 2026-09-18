local curl_wrapper = {}
curl_wrapper.__index = curl_wrapper

---Creates a new curl_wrapper instance with its own configuration.
---Use this to create wrappers for other websites.
---@param config CurlWrapperConfig
---@return CurlWrapper
function curl_wrapper.new(config)
	local instance = {
		base_url = config.base_url,
		default_headers = config.default_headers or {},
		timeout_ms = config.timeout_ms or 10000,
		min_request_interval_ms = config.min_request_interval_ms or 1000,
		last_request_time = 0,
	}
	return setmetatable(instance, curl_wrapper)
end

---Makes the HTTP request. You probably wouldn't need
---to call this directly. Default flags used:
--- -s=silent
--- -X=method
--- --max-time=timeout
--- -H=headers
--- -d=request body
---@param endpoint string
---@param method HTTPMethods
---@param opts CurlRequestOpts
---@return CurlResponse
function curl_wrapper:request(endpoint, method, opts)
	opts = opts or {}
	local url = self.base_url .. endpoint
	local args = { "curl", "-s", "-X", method, "--max-time", tostring(self.timeout_ms / 1000) }

	for key, value in pairs(self.default_headers) do
		table.insert(args, "-H")
		table.insert(args, key .. ": " .. value)
	end

	if opts.body then
		table.insert(args, "-d")
		table.insert(args, vim.json.encode(opts.body))
	end

	table.insert(args, url)
	local curlFunction = function()
		self.last_request_time = vim.uv.now()
		vim.system(args, { text = true }, function(result)
			if opts.callback then
				--- @type CurlResponse
				local response = {
					ok = result.code == 0,
					exit_code = result.code,
					body = result.stdout or "",
					err = result.stderr or "",
				}
				opts.callback(response)
			end
		end)
	end

	if self.last_request_time and vim.uv.now() - self.last_request_time <= self.min_request_interval_ms then
		vim.defer_fn(curlFunction, self.timeout_ms)
	else
		curlFunction()
	end
end

---Makes a GET call to the given endpoint.
---@param endpoint string
---@param opts CurlRequestOpts
---@return CurlResponse
function curl_wrapper:get(endpoint, opts)
	return self:request(endpoint, "GET", opts)
end

return curl_wrapper
