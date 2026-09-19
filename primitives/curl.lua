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

---Makes the HTTP request async. You probably wouldn't need
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
	-- TODO: Remove \n%{http_code} from the body.
	local curlFunction = function()
		self.last_request_time = vim.uv.now()
		vim.system(args, { text = true }, function(result)
			--- @type number
			local http_code = tonumber(string.match(result.stdout, "(%d%d%d)$")) or 0
			--- @type CurlResponse
			local response = {
				ok = result.code == 0 and http_code >= 200 and http_code < 300,
				exit_code = result.code,
				http_status_code = http_code,
				body = result.stdout or "",
				err = result.stderr or "",
			}
			opts.callback(response)
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
