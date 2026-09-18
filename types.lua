---@class CurlWrapper
---@field base_url string
---@field default_headers table<string, string>
---@field timeout_ms number
---@field min_request_interval_ms number
---@field last_request_time number

---@class CurlWrapperConfig
---@field base_url string
---@field default_headers table<string, string>|nil
---@field timeout_ms number|nil
---@field min_request_interval_ms number|nil

---Raw response received after CURL.
---Probably needs to be parsed.
---@class CurlResponse
---@field ok boolean
---@field exit_code number
---@field body string
---@field err string

---Body of the request. Callback to be fired
---after receiving the response.
---@class CurlRequestOpts
---@field body table|nil
---@field callback fun(response: CurlResponse)|nil

---If we ever decide to add support for submitting
---solutions, add POST here.
---@alias HTTPMethods
---| "GET"

---@class TestCase
---@field input string
---@field output string

---@class ParsedProblem
---@field problemId integer
---@field problemStatement string
---@field sampleCases TestCase[]
---@field constraints string

---@class LanguageConfig
---@field fileExtensions string[]
---@field compileCommand string
---@field runCommand string

---@class TestResult
---@field caseId integer
---@field passed boolean
---@field actualOutput string
---@field expectedOutput string
---@field durationMs number
