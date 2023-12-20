---@type lfs
local lfs = require("lfs")

---comment
local function not_implemented()
	error("not implemented!", 2)
end

local function inspect(o, opts)
	opts = opts or {}
	opts.indent = opts.indent or 0

	if type(o) == "table" then
		local result = { "{" }
		local indent = string.rep(" ", opts.indent + 2)
		for k, v in pairs(o) do
			table.insert(result, string.format("%s%s=%s", indent, k, inspect(v, { indent = indent })))
		end
		table.insert(result, "}")
		return table.concat(result, "")
	else
		return string.format("%s", o or "nil")
	end
end

---@class Path
---@field path string
---@overload fun(...: PathLike): Path
local Path = {}

---@alias RawPath { path: string }
---@alias PathLike Path | RawPath | string | nil

Path.root_dir = "/"
Path.path_sep = "/"
Path.cur_dir = "."
Path.parent_dir = ".."
Path.user_dir = "~"

-- ------------------------------------------------------------------------
-- | Private Helper Methods
-- ------------------------------------------------------------------------

local function startswith(s, t)
	return s:sub(1, t:len()) == t
end

local function endswith(s, t)
	return s:sub(-t:len()) == t
end

local is_absolute = function(s)
	return startswith(s, Path.root_dir)
end

---Normalizes a given string path.
---The returned path is guaranteed to have
---  1. Single path separators
---  2. No trailing slashes
---Current directories aren't normalized, and neither are parent directories.
---@param path string
---@return string
local function normalize_string_path(path)
	path = path:gsub(Path.path_sep .. "*", Path.path_sep)

	-- If the path is just the root directory, we can return early.
	if path == Path.root_dir then
		return path
	end

	-- Trim a trailing path separator.
	path = path:gsub(Path.path_sep .. "$", "")

	return path
end

---Converts a PathLike type into an actual raw path.
---@param pathlike PathLike
---@return string
local function pathlike_to_string(pathlike)
	if pathlike == nil then
		return Path.cur_dir
	elseif type(pathlike) == "string" then
		return pathlike
	elseif type(pathlike) == "table" and pathlike.path ~= nil then
		return pathlike.path
	else
		error("invalid type for path")
	end
end

-- ------------------------------------------------------------------------
-- | Constructor
-- ------------------------------------------------------------------------

---comment
---@param pathlike PathLike
---@return Path
function Path:new(pathlike)
	local path = {
		normalize_string_path(pathlike_to_string(pathlike)),
	}

	setmetatable(path, {
		__index = self,
		__tostring = self.tostring,
		__div = self.join,
		__concat = self.join,
	})

	return path
end

---@return Path
function Path.cwd()
	local cwd, msg = lfs.current_dir()
	if cwd == nil then
		error(string.format("Unable to get current working directory: %s", msg))
	end

	return Path:new(cwd)
end

---@return Path
function Path.home()
	local home_dir = os.getenv("HOME")
	if home_dir == nil then
		error("HOME not set in environment")
	end

	return Path:new(home_dir)
end

-- ------------------------------------------------------------------------
-- | Path Operations
-- ------------------------------------------------------------------------

---comment
---@param ... PathLike
---@return Path
function Path:join(...)
	local result = { self.path }

	for _, path in ipairs(table.pack(...)) do
		path = pathlike_to_string(path)
		if is_absolute(path) then
			result = { path }
		else
			table.insert(result, path)
		end
	end

	return Path:new(table.concat(result, Path.path_sep))
end

---comment
---@param other PathLike Unless walk_up is set to true, other must be a prefix
---of the current path.
---@param opts {walk_up: boolean}
---@return Path
function Path:relative_to(other, opts)
	other = Path:new(other)

	opts = opts or {}
	opts.walk_up = opts.walk_up ~= nil and opts.walk_up or false

	if opts.walk_up then
		not_implemented()
	else
		local prefix_len = other.path:len()
		local prefix = self.path:sub(1, prefix_len)
		if prefix ~= other then
			error("'%s' must be a prefix of '%s'", 2)
		end

		return Path:new(other):join(self.path:sub(prefix_len + 1))
	end

	return Path:new()
end

-- ------------------------------------------------------------------------
-- | Part Operations
-- ------------------------------------------------------------------------

---comment
---@return string[]
function Path:parts()
	local parts
	if self:is_absolute() then
		parts = { Path.root_dir }
	else
		parts = {}
	end

	for match in self.path:gmatch("[^" .. Path.path_sep .. "]+") do
		table.insert(parts, match)
	end

	return parts
end

function Path:parent()
	local last = self.path:find(Path.path_sep .. "+[^" .. Path.path_sep .. "]+" .. Path.path_sep .. "*$")
	if last == nil then
		return Path:new(Path.root_dir)
	else
		return self:new(self.path:sub(1, last - 1))
	end
end

---Returns a list of all parents of the current path.
---@return Path[]
function Path:parents()
	local path = self
	local parents = {}

	while path ~= "/" do
		path = path:parent()
		table.insert(parents, path)
	end

	return parents
end

function Path:name()
	not_implemented()
end

function Path:stem()
	not_implemented()
end

function Path:suffix()
	not_implemented()
end

function Path:suffixes()
	not_implemented()
end

-- ------------------------------------------------------------------------
-- | Modify Parts
-- ------------------------------------------------------------------------

function Path:with_name()
	not_implemented()
end

function Path:with_stem()
	not_implemented()
end

function Path:with_suffix()
	not_implemented()
end

-- ------------------------------------------------------------------------
-- | Attributes
-- ------------------------------------------------------------------------

---comment
---@return LfsAttributes
function Path:stat()
	return lfs.attributes(self.path)
end

---If the current path is a symlink, reeturn the attributes of the symlink
---itself, not the file it points to.
---@return LfsSymlinkAttributes
function Path:lstat()
	return lfs.symlinkattributes(self.path)
end

---comment
---@return boolean
function Path:exists()
	not_implemented()
end

---comment
---@return boolean
function Path:is_file()
	not_implemented()
end

---comment
---@return boolean
function Path:is_dir()
	not_implemented()
end

---comment
---@return boolean
function Path:is_symlink()
	not_implemented()
end

---comment
---@return boolean
function Path:is_socket()
	not_implemented()
end

---comment
---@return boolean
function Path:is_fifo()
	not_implemented()
end

---comment
---@return boolean
function Path:is_block_device()
	not_implemented()
end

---comment
---@return boolean
function Path:is_char_device()
	not_implemented()
end

---comment
---@return boolean
function Path:is_executable()
	not_implemented()
end

---comment
---@param other PathLike
---@return boolean
function Path:is_samefile(other)
	not_implemented()
end

---comment
---@return boolean
function Path:is_absolute()
	not_implemented()
end

---comment
---@return boolean
function Path:is_relative()
	not_implemented()
end

---comment
---@param other PathLike
---@return boolean
function Path:is_relative_to(other)
	not_implemented()
end

-- ------------------------------------------------------------------------
-- | Symlink Operations
-- ------------------------------------------------------------------------

---Read the value of the symlink if the current path is a symlink.
---@return Path
function Path:readlink()
	---@diagnostic disable-next-line: param-type-mismatch
	return Path:new(lfs.symlinkattributes(self.path, "target"))
end

---comment
---@return Path
function Path:resolve()
	---@diagnostic disable-next-line: param-type-mismatch
	return Path:new(lfs.symlinkattributes(self.path, "target"))
end

---comment
---@return Path
function Path:expand_user()
	return Path:new(self.path:gsub("^~", Path.home().path, 1))
end

---comment
---@return Path
function Path:absolute()
	not_implemented()
end

-- ------------------------------------------------------------------------
-- | File System Exploration
-- ------------------------------------------------------------------------

---Return the contents of the directory if the current path is a directory.
---@return Path[]
function Path:dir()
	not_implemented()
end

---Return the contents of the directory and all child directories if the current
---path is a directory.
---@return Path[]
function Path:walk()
	not_implemented()
end

-- ------------------------------------------------------------------------
-- | File System Operations
-- ------------------------------------------------------------------------

function Path:chmod()
	not_implemented()
end

---Update access and or modification time.
---@param atime integer?
---@param mtime integer?
function Path:touch(atime, mtime)
	lfs.touch(self.path, atime, mtime)
end

function Path:rmdir()
	lfs.rmdir(self.path)
end

---comment
---@param opts {parents: boolean, exists_ok: boolean}?
function Path:mkdir(opts)
	opts = opts or {}
	opts.parents = opts.parents ~= nil and opts.parents or false
	opts.exists_ok = opts.exists_ok ~= nil and opts.exists_ok or false
	lfs.mkdir(self.path)
end

---comment
---@param target PathLike
function Path:symlink_to(target)
	target = pathlike_to_raw_path(target)
	lfs.link(self.path, target.path, true)
end

---comment
---@param target PathLike
function Path:link_to(target)
	target = pathlike_to_raw_path(target)
	lfs.link(self.path, target.path, false)
end

function Path:unlink()
	if self:is_symlink() then
		os.remove(self.path)
	end
end

---comment
---@param target PathLike
function Path:rename(target)
	target = pathlike_to_raw_path(target)
	if Path:new(target):exists() then
		error(string.format("target file already exists: %s"), 2)
	end

	os.rename(self.path, target.path)
end

---comment
---@param target PathLike
function Path:replace(target)
	target = pathlike_to_raw_path(target)
	if not Path:new(target):exists() then
		error(string.format("target file does not exist, so it cannot be replaced: %s", target.path), 2)
	end

	os.rename(self.path, target.path)
end

---comment
---@param contents string
function Path:write(contents)
	not_implemented()
end

-- ------------------------------------------------------------------------
-- | Glob Matching
-- ------------------------------------------------------------------------

---Match the current path against the glob pattern.
---@param glob string
function Path:match(glob)
	not_implemented()
end

---Glob the given relative pattern in the directory represented by this path,
---retiring a list of all matching files.
---@param glob string
function Path:glob(glob)
	not_implemented()
end

-- ------------------------------------------------------------------------
-- | Path Object Meta
-- ------------------------------------------------------------------------

---comment
---@return string
function Path:tostring()
	return self.path
end

-- ------------------------------------------------------------------------
-- | Path Table Meta
-- ------------------------------------------------------------------------

---@diagnostic disable-next-line: param-type-mismatch
setmetatable(Path, {
	__call = Path.new,
})

return Path
