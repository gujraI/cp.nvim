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

---Makes the async HTTP request. You probably wouldn't need
---to call this directly. Pass a callback to get the o/p.
---@param endpoint string
---@param method HTTPMethods
---@param opts CurlRequestOpts
function curl_wrapper:request(endpoint, method, opts)
	opts = opts or {}
	local url = self.base_url .. endpoint
	local args = { "curl", "-s", "-X", method, "--max-time", tostring(self.timeout_ms / 1000), "-w", "\n%{http_code}" }

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
			local http_response, http_code = result.stdout:match("^(.*)\n(%d%d%d)$")
			http_code = tonumber(http_code) or -1
			http_response = http_response or result.stdout
			--- @type CurlResponse
			local response = {
				ok = result.code == 0 and http_code >= 200 and http_code < 300,
				exit_code = result.code,
				http_status_code = http_code,
				body = http_response or "",
				err = result.stderr or "",
			}
			if opts.callback then
				opts.callback(response)
			end
		end)
	end

	local elapsed = vim.uv.now() - self.last_request_time
	if self.last_request_time and elapsed <= self.min_request_interval_ms then
		vim.defer_fn(curlFunction, self.min_request_interval_ms - elapsed)
	else
		curlFunction()
	end
end

---Makes a GET call to the given endpoint.
---@param endpoint string
---@param opts CurlRequestOpts
function curl_wrapper:get(endpoint, opts)
	return self:request(endpoint, "GET", opts)
end

return curl_wrapper
