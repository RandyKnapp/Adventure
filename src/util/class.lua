-- Copyright (c) 2012 Roland Yonaba
--[[
This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

    1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software
    in a product, an acknowledgment in the product documentation would be
    appreciated but is not required.

    2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.

    3. This notice may not be removed or altered from any source
    distribution.
--]]


local pairs,ipairs = pairs,ipairs
local assert = assert
local setmetatable, getmetatable = setmetatable, getmetatable
local type = type
local insert = table.insert

-- Internal register
local _register = setmetatable({ class = {}, object = {}},{__mode='k'})

-- Checks if thing is a kind or whether an 'object' or 'class'
local function isA(thing,kind)
  if kind then
    assert(kind == 'object' or kind == 'class',
      'When given, string \'kind\' must be a \'class\' or an \'object\'')
  end
  if thing then
    if _register.class[thing] then
      return kind and _register.class[thing].__system.__type == kind
                   or _register.class[thing].__system.__type
    elseif _register.object[thing] then
      return kind and _register.object[thing].__system.__type == kind
                   or _register.object[thing].__system.__type
    end

  end
  return false
end

-- tostring
local function __tostring(self,...)
  if self.describe then return self:describe(...) end
  local is = isA(self)
  if is then
    return ('%s: <%s>'):format(is,_register[is][self].__system.__addr)
  end
  return tostring(self)
end

-- Base metatable
local baseClassMt = {
  __call = function (self,...) return self:new(...) end,
  __tostring = __tostring
  }

local Class

-- Simple helper for building a raw copy of a table
-- Only pointers to classes or objects stored as instances are preserved
local function deep_copy(t)
  local r = {}
  for k,v in pairs(t) do
    if type(v) == 'table' then
      if (_register.class[v] or _register.object[v]) then r[k] = v
      else r[k] = deep_copy(v)
      end
    else r[k] = v
    end
  end
  return r
end

-- Checks for a method in a list of attributes
local function checkForMethod(list)
  for k,attr in pairs(list) do
    assert(type(attr)~='function','Cannot assign functions as members')
  end
end

-- Instantiation
local function instantiateFromClass(self,...)
  assert(isA(self,'class'),'Class constructor must be called from a class')
  assert(not _register.class[self].__system.__abstract, 'Cannot instantiate from abstract class')
  local instance = deep_copy(self)
  _register.object[instance] = {
    __system = {
      __type = 'object',
      __superClass = self,
      __addr = tostring(instance),
    }
  }
  local instance = setmetatable(instance,self)
    if self.constructor then
      self.constructor(instance, ...)
    end
  return instance
end

-- Class derivation
local function extendsFromClass(self,extra_params)
  assert(isA(self,'class'),'Inheritance must be called from a class')
  assert(not _register.class[self].__system.__final, 'Cannot derive from a final class')
  local class = Class(extra_params)
  class.__index = class
  class.__tostring = __tostring
  _register.class[class].__system.__superClass = self
  _register.class[self].__system.__subClass[class] = true
  return setmetatable(class,self)
end

-- Abstract class deriviation
local function abstractExtendsFromClass(self, extra_params)
  local c = self:extends(extra_params)
  _register.class[c].__system.__abstract = true
  return c
end

-- Final class deriviation
local function finalExtendsFromClass(self, extra_params)
  local c = self:extends(extra_params)
  _register.class[c].__system.__final = true
  return c
end

-- Super methods call
local function callFromSuperClass(self,f,...)
  local superClass = getmetatable(self)
  if not superClass then return nil end
  local super = _register.class[superClass].__system.__superClass
  local s = self
  while s[f] == super[f] do
    s = super
    super = _register.class[super].__system.__superClass
  end

  -- If the superclass also has a superclass, temporarily set :super to call THAT superclass' methods
  local supersSuper = _register.class[super].__system.__superClass
  if supersSuper then
    _register.class[superClass].__system.__superClass = supersSuper
  end

  local method = super[f]
  local result = method(self,...)

  -- And set the superclass back, if necessary
  if supersSuper then
    _register.class[superClass].__system.__superClass = super
  end
  return result
end

-- Gets the superclass
local function getSuperClass(self)
  local super = getmetatable(self)
  return (super ~= baseClassMt and super or nil)
end

-- Gets the subclasses
local function getSubClasses(self)
  assert(isA(self,'class'),'getSubClasses() must be called from class')
  return _register.class[self].__system.__subClass or {}
end

-- Class creation
Class = function(members)
  if members then checkForMethod(members) end
  local newClass = members and deep_copy(members) or {}                              -- includes class variables
  newClass.__index = newClass                                                        -- prepares class for inheritance
  _register.class[newClass] = {__system = {                                          -- builds information for internal handling
      __type = "class",
      __abstract = abstract or false,
      __final = final or false,
      __superClass = false,
      __subClass = {},
      __addr = tostring(newClass)
    }
  }

  newClass.new = instantiateFromClass                                                -- class instanciation
  newClass.extends = extendsFromClass                                                -- class derivation
  newClass.abstractExtends = abstractExtendsFromClass                                -- abstract class deriviation
  newClass.finalExtends = finalExtendsFromClass                                      -- final class deriviation
  newClass.__call = baseClassMt.__call                                               -- shortcut for instantiation with class() call
  newClass.super = callFromSuperClass                                                -- super method calls handling
  newClass.getClass = getSuperClass                                                  -- gets the superclass
  newClass.getSubClasses = getSubClasses                                             -- gets the subclasses
  newClass.__tostring = __tostring                                                   -- tostring
  newClass.isA = function(self,aClass,shallow)                                              -- Object's class checking
    assert(isA(self,'object'),'isA() must be called from an object')
    if aClass then
      assert(isA(aClass,'class'),'When given, Argument must be a class')
      local target = self
      repeat
        local superclass = target:getClass()
        if superclass == aClass then return true end
        target = superclass
      until (not superclass or shallow)
      return false
    else
      return self:getClass()
    end
  end

  return setmetatable(newClass,baseClassMt)
end

-- Static classes
local function abstractClass(members)
  local class = Class(members)
  _register.class[class].__system.__abstract = true
  return class
end

-- Final classes
local function finalClass(members)
  local class = Class(members)
  _register.class[class].__system.__final = true
  return class
end

-- Returns utilities packed in a table (in order to avoid polluting the global environment)
return {
      _VERSION = "1.2.1",
      isA = isA,
      define = setmetatable({
        abstract = abstractClass,
        final = finalClass},
      {__call = function(self,...) return Class(...) end}),
    }

-- local class = require 'util.class'
