# -*- coding: utf-8 -*-

# Copyright (C) 2011 Atelier Obscur.
# Authors:
# Gilles Coissac <dev@atelierobscur.org>

# This program is free software; you can redistribute it and/or modify
# it under the terms of version 2 of the GNU General Public License
# as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License with
# the Debian GNU/Linux distribution in file /usr/share/common-licenses/GPL;
# if not, write to the Free Software Foundation, Inc., 51 Franklin St,
# Fifth Floor, Boston, MA 02110-1301, USA.


# - properties should be usable by python code to build automatic interface.
# - properties are group in propertyList object to define the whole user parameters
#   for a specific execution task.
# - propertyList are serializable in the form of an xml file.
# - a property is statically typed, could have restricted values - some boundaries -,
#   have a default value
# - static typing should follow python typing, no c-type
# - properties should have a constraint mechanism within a propertyList,
#   so some value or property availability could be affected by another  property.
# - property have an ui name, a description field and there should be localizable
# - propertyList could group properties to better ui presentation

cimport cython

import warnings
from numbers import Number
from collections import OrderedDict as ODict
from xml.etree import ElementTree as ETree
from xml.dom import minidom
import codecs, datetime

#TODO: write / read from file method for propertyList
#TODO: provide a way to handle versions change between a propertylist on file and in memory
#TODO: add arithmetics and comparaison method to property --> delegate this to the encapsuled tpe
#TODO: PropertyList methods to extract subset properties dependent on the group or by specifing a special tag attribute
#TODO: invalid value on property warns user, should this generate an special event?
#TODO: make doc
#TODO: make test
#TODO: __doc__ localisation


# Abstract property base type Class
class basetype:
    @staticmethod
    def validateargs(object dic, Property prop):
         raise NotImplementedError("This is an abstract class")

    @staticmethod
    def getdefault(Property prop):
        raise NotImplementedError("This is an abstract class")

    @staticmethod
    def validate_value(object val, Property prop):
        raise NotImplementedError("This is an abstract class")

    @staticmethod
    def length(object val, Property prop):
        raise NotImplementedError("This is an abstract class")

    @staticmethod
    def tostring():
        raise NotImplementedError("This is an abstract class")

# Atomic int type
class Int(basetype):
    @staticmethod
    def validateargs(object dic, Property prop):
        #testing value range
        if "valuerange" in dic:
            valuerange = dic['valuerange']
            if not isinstance(valuerange, tuple) and valuerange is not None:
                raise ValueError("valuerange attribute should be a two tuple length or None, given", valuerange)
            if valuerange is None:
                valuerange = (None, None)
        else :
            valuerange = (None, None)
        if Int.valuerange_is_valid(valuerange):
            prop.addattr['valuerange'] = valuerange

    @staticmethod
    def valuerange_is_valid(tuple vals):
        if len(vals) > 2:
            raise ValueError("valuerange shoulb be a two length tuple")
        for v in vals:
            if v is not None and not isinstance(v, Number):
                raise ValueError("value for range should be an int or None")
        if vals[1] is not None and vals[0] is not None and vals[1] > vals[0]:
            raise ValueError("second value for range should be >= to first value %s" %str(vals))
        return True

    @staticmethod
    def getdefault(Property prop):
        if prop.valuerange[0] == None:
            if prop.valuerange[1] == None:
                return 0
            else:
                return min(0, prop.valuerange[1])
        else:
            return min(0, prop.valuerange[0])

    @staticmethod
    def validate_value(object val, Property prop):
        if val == None:
            return Int.getdefault(prop)
        if not isinstance(val, int):
            try:
                val = int(val)
            except ValueError:
                warnings.warn("Invalid value type : %s" %str(val))
                return prop._value
        if prop.valuerange[0] is not None and val < prop.valuerange[0]:
            warnings.warn("Invalid value, %i out of range [%i, %i]" %(val, prop.valuerange[0], prop.valuerange[1]))
            return prop._value
        if prop.valuerange[1] is not None and val > prop.valuerange[1]:
            warnings.warn("Invalid value, %i out of range [%i, %i]" %(val, prop.valuerange[0], prop.valuerange[1]))
            return prop._value
        return val

    @staticmethod
    def length(object val, Property prop):
        return 1

    @staticmethod
    def tostring():
        return "Int"

 # Atomic float type
class Float(basetype):
    @staticmethod
    def validateargs(object dic, Property prop):
        #testing value range
        if "valuerange" in dic:
            valuerange = dic['valuerange']
            if not isinstance(valuerange, tuple) and valuerange is not None:
                raise ValueError("valuerange attribute should be a two tuple length or None, given", valuerange)
            if valuerange is None:
                valuerange = (None, None)
        else :
            valuerange = (None, None)
        if Float.valuerange_is_valid(valuerange):
            prop.addattr['valuerange'] = valuerange

    @staticmethod
    def valuerange_is_valid(tuple vals):
        if len(vals) > 2:
            raise ValueError("valuerange shoulb be a two length tuple")
        for v in vals:
            if v is not None and not isinstance(v, Number):
                raise ValueError("value for range should be an Number or None")
        if vals[1] > vals[0]:
            raise ValueError("second value for range should be >= to first value %s" %str(vals))
        return True

    @staticmethod
    def getdefault(Property prop):
        if prop.valuerange[0] == None:
            if prop.valuerange[1] == None:
                return .0
            else:
                return min(.0, prop.valuerange[1])
        else:
            return min(.0, prop.valuerange[0])

    @staticmethod
    def validate_value(object val, Property prop):
        if val == None:
            return Float.getdefault(prop)
        if not isinstance(val, float):
            try:
                val = float(val)
            except ValueError:
                warnings.warn("Invalid value type : %s" %str(val))
                return prop._value
        if prop.valuerange[0] is not None and val < prop.valuerange[0]:
            warnings.warn("Invalid value, %f out of range [%f, %f]" %(val, prop.valuerange[0], prop.valuerange[1]))
            return prop._value
        if prop.valuerange[1] is not None and val > prop.valuerange[1]:
            warnings.warn("Invalid value, %f out of range [%f, %f]" %(val, prop.valuerange[0], prop.valuerange[1]))
            return prop._value
        return val

    @staticmethod
    def length(object val, Property prop):
        return 1

    @staticmethod
    def tostring():
        return "Float"

# Atomic boolean type
class Boolean(basetype):
    @staticmethod
    def validateargs(object dic, Property prop):
        #Nothing needed
        return None

    @staticmethod
    def getdefault(Property prop):
        return (True if prop._value else False)

    @staticmethod
    def validate_value(object val, Property prop):
        if val == None:
            return Boolean.getdefault(prop)
        else:
            return (True if val else False)

    @staticmethod
    def length(object val, Property prop):
        return 1

    @staticmethod
    def tostring():
        return "Boolean"

# picklist type
class Picklist(basetype):
    @staticmethod
    def validateargs(object dic, Property prop):
        #looking for valueslist
        if "values" in dic:
            values = dic['values']
            if values is None or not isinstance(values, (list, tuple)) or len(values)==0:
                raise ValueError("'values' attribute should be a list or tuple of objects, given", values)
            values = [str(v) for v in values]
        else :
            raise AttributeError("the picklist type need a 'values' named argument")
        prop.addattr['values'] = values

    @staticmethod
    def getdefault(Property prop):
        return prop.addattr['values'][0]

    @staticmethod
    def validate_value(object val, Property prop):
        if val == None:
            return Picklist.getdefault(prop)
        if str(val) not in prop.addattr['values']:
            warnings.warn("Invalid value, %s is not a predefined value (%s)" %(str(val), str(prop.addattr['values'])))
            return prop._value
        return val

    @staticmethod
    def length(object val, Property prop):
        return 1

    @staticmethod
    def tostring():
        return "Picklist"

# list type
class List(basetype):
    @staticmethod
    def validateargs(object dic, Property prop):
        if "types" in dic:
            types = dic['types']
            if not isinstance(types, (list, tuple)) and types is not None :
                raise ValueError("'types' attribute should be a list or tuple of type(s), given", types)
            if types is None or len(types) == 0:
                types = None
            else:
                types = [v for v in types]
        else:
            types = None
        prop.addattr['types'] = types

        if "lengthrange" in dic:
            lengthrange = dic['lengthrange']
            if not isinstance(lengthrange, tuple) and lengthrange is not None:
                raise ValueError("lengthrange attribute should be a two tuple length or None, given", lengthrange)
            if lengthrange is None:
                lengthrange = (0, None)
            elif lengthrange[0] == None:
                lengthrange = (0, lengthrange[1])
        else :
            lengthrange = (0, None)
        if List.lengthrange_is_valid(lengthrange):
            prop.addattr['lengthrange'] = lengthrange

        if lengthrange[0] == 0 and not 'default' in dic:
            default = []
        elif 'default' in dic:
            default = dic['default']
            if types is not None:
                for v in default:
                    if not isinstance(v, tuple(types)):
                        raise AttributeError('default list attribute contains a non valid type - %s not in %s' %(str(v), str(types)))
            if len(default) < lengthrange[0]:
                raise AttributeError('default length of list attribute not in range(%s, %s)' %(str(lengthrange[0]), str(lengthrange[1])))
            if lengthrange[1] is not None and len(default) > lengthrange[1]:
                raise AttributeError('default length of list attribute not in range(%s, %s)' %(str(lengthrange[0]), str(lengthrange[1])))
        else:
            raise AttributeError("'default' list attribute is mandatory for List type, None given")
        prop.addattr['default'] = default


    @staticmethod
    def lengthrange_is_valid(tuple vals):
        if len(vals) > 2:
            raise ValueError("length range shoulb be a two length tuple")
        for v in vals:
            if v is not None:
                if not isinstance(v, int):
                    raise ValueError("value for range should be an int or None")
                elif  v < 0:
                    raise ValueError("value for range can't be negative")
        if vals[1] is not None and vals[1] > vals[0]:
            raise ValueError("second value for range should be >= to first value %s" %str(vals))
        return True

    @staticmethod
    def getdefault(Property prop):
        return prop.addattr['default']

    @staticmethod
    def validate_value(object val, Property prop):
        if val is None:
            return List.getdefault(prop)
        else:
            val = list(val)
            if prop.types is not None:
                for v in val:
                    if not isinstance(v, tuple(prop.types)):
                        warnings.warn("Invalid value type : %s not in %s" %(str(type(val), str(prop.types))))
                        return prop._value
            if len(val) < prop.lengthrange[0]:
                warnings.warn("Invalid value, length %i of list attribute not in range(%s, %s)'" %(len(val), prop.lengthrange[0], prop.lengthrange[1]))
                return prop._value
            if prop.lengthrange[1] is not None and len(val) > prop.lengthrange[1]:
                warnings.warn("Invalid value, length %i of list attribute not in range(%s, %s)'" %(len(val), prop.lengthrange[0], prop.lengthrange[1]))
                return prop._value
            return val

    @staticmethod
    def length(object val, Property prop):
        return len(val)

    @staticmethod
    def tostring():
        return "List"


cdef class Constraint:
    cdef public Property master
    cdef public object _apply_func

    def __init__(self, Property master, function):
        if not isinstance(master, Property):
            raise TypeError("attributes can only be Property (not %s)" %str(type(master)))
        self.master = master
        if not callable(function):
            raise TypeError("function attribute should be callable")
        self._apply_func = function

    def apply(self, Property slave):
        self._apply_func(self.master.state, self.master.value, slave)

    def __repr__(self):
        return self.__class__.__name__ + "(master=\"%s\", %s)" %(self.master._name, repr(self._apply_func))


cdef class Event:
    cdef public object notifier
    cdef public object event

    def __init__(self, notifier, event):
        self.notifier = notifier
        self.event = event

    def __str__(self):
        return 'event %s from %s' %(self.event, repr(self.notifier))


cdef class __Listener:
    cdef public list callbacks
    cdef public object ref

    def __init__(self, object ref, callback=None):
        if ref is None:
            raise AttributeError("referent object can't be None")
        self.callbacks = []
        self.ref = ref
        if callback is not None:
            self.setcallback(callback, False)

    def setcallback(self, object callback, replace=False):
        if callback is None:
            raise AttributeError("callback attribute can't be None")
        elif not callable(callback):
            raise AttributeError("callback attribute should be callable")
        if replace:
            del(self.callbacks[:])
        else:
            for c in self.callbacks:
                if c is callback:
                    return
            self.callbacks.append(callback)

    def removecallback(self, object callback not None):
        try:
            self.callbacks.remove(callback)
        except:
            pass

    def notify(self, event):
        for c in self.callbacks:
            if isinstance(self.ref, object):
                c(self.ref, event)
            else:
                c(event)

    property havecallback:
        def __get__(self):
            if len(self.callbacks)==0:
                return False
            else:
                return True


cdef int Property_id = 0

cdef class Property:
    """
    Property object hold typed attribute for higher level user acces.

    A Property is build to be add as a member of any object in the most
    pythonic way with the less overhead - with short verbose - and to expose
    a rich interface and flexible mechanism to present public attributes to
    high level programming like quickly building meaningful graphical
    user interface, serializing set of attributes (preferences) for an application
    in a human readable XML formatted text document.
    """
    cdef object _value
    cdef type _dtype
    cdef str _name
    cdef int _id
    cdef bint enabled
    cdef bint visible
    cdef object __doc__
    cdef dict addattr
    cdef Constraint _constraint
    cdef public list listeners

    def __init__(Property self, name=None, dtype=Int, value=None,
                     doc=None, constraint=None, state=(True, True), **kwargs):

        global Property_id

        # Testing datatype attribute
        if not issubclass(dtype, basetype):
            raise TypeError("dtype attribute should be a valid Propertype subclass")
        else:
            self._dtype = dtype

        self.listeners = []

        # additional arguments dict specific to each type
        self.addattr = {}
        if kwargs is not None:
            for k, v in kwargs.iteritems():
                self.addattr[k] = v
        self._dtype.validateargs(self.addattr, self)

        #name & doc
        Property_id += 1
        self._id = Property_id
        self._name = str(name) if name is not None else  "property_" + str(self._id)
        self.__doc__ = str(doc) if doc is not None else ""

        #value
        self.value = value

        #State properties
        self.enabled, self.visible = state

        #constraint
        self.constraint = constraint


    #
    # Events methods
    #
    def bind(self, object callback, replace=False):
        cdef int i
        cdef object ref

        if hasattr(callback, '__self__'):
            ref = callback.__self__
        else:
            ref = callback.__module__

        for refs in self.listeners:
            if refs.ref is ref:
                i = self.listeners.index(refs)
                self.listeners[i].setcallback(callback, replace)
                break
        else:
            self.listeners.append(__Listener(ref, callback))

    def unbind(self, object callback):
        cdef int i
        cdef object ref

        if hasattr(callback, '__self__'):
            ref = callback.__self__
        else:
            ref = callback.__module__
        for refs in self.listeners:
            if refs.ref is ref:
                i = self.listeners.index(refs)
                self.listeners[i].removecallback(callback)
                if not self.listeners.havecallback:
                    self.listeners.remove(refs)
                break

    cdef notify(Property self, status):
        cdef object ref
        event = Event(self, status)
        for refs in self.listeners:
            refs.notify(event)

    def __constraint_callback(self, event):
        self._constraint.apply(self)

    #
    # sequence methods
    #
    def __len__(self):
        return self._dtype.length(self._value, self)

    #
    # Attributes access methods
    #
    def __getattr__(Property self, name):
        if name in self.addattr:
            return self.addattr[name]
        else:
            raise AttributeError("Property have no attribute %s" %name)

    # constraint need this to change behavior of properties
    #NOTE: __setattr__ cython method shortcut setter method of
    # property descriptors defined below with no way to redirect
    # to them, so setter method for this property are implemented here.
    def __setattr__(Property self, name, val):
        if name in self.addattr:
            self.addattr[name] = val
            # if val is a needed dtype attribute, check if it's value is ok
            self._dtype.validateargs(self.addattr, self)
            self.notify(name)

        elif name == 'constraint':
            v = self._constraint
            if val is not None:
                if not isinstance(val, Constraint):
                    raise TypeError("Need a property.Constraint instance, not %s" %(type(val)))
                if val.master == self:
                    raise ValueError("master and slave property can't be the same instance")
            if val is not None:
                self._constraint = val
                self._constraint.master.bind(self.__constraint_callback)
                self._constraint.apply(self)
            else:
                if self._constraint is not None:
                    self._constraint.master.unbind(self.__constraint_callback)
                self._constraint = val
            if v != self._constraint:
                self.notify(name)

        elif name == 'value':
            v = self._value
            if self._constraint is not None:
                self._constraint.apply(self)
            self._value = self._dtype.validate_value(val, self)
            if v != self._value:
                self.notify(name)

        elif name == 'state':
            v = (self.enabled, self.visible)
            if isinstance(val, tuple):
                self.enabled = bool(val[0])
                self.visible = bool(val[1])
            else:
                self.enabled = bool(val)
            if (self.enabled, self.visible) != v:
                self.notify(name)

        elif name == 'doc' or  name == '__doc__':
             self.__doc__ = str(val)

        else:
            raise AttributeError("Property have no attribute %s" %name)

    #
    # properties descriptors
    #
    property constraint:
        def __get__(self):
            return self._constraint

        #def __set__(Property self, val):
        #see @ __setattr__()

        def __del__(self):
            self.constraint = None

    property value:
        def __get__(self):
            return self._value

        #def __set__(self, value):
        #see @ __setattr__()

    property state:
        def __get__(self):
            return self.enabled, self.visible

        #def __set__(self, value):
        #see @ __setattr__()

    property dtype:
        def __get__(self):
            return self._dtype

    property name:
        def __get__(self):
            return self._name

    property doc:
        def __get__(self):
            return self.__doc__

        #def __set__(self, val):
        #see @ __setattr__()

    property __doc__:
        def __get__(self):
            return self.__doc__

        #def __set__(self, val):
        #see @ __setattr__()

    def __repr__(self):
        repr_s = self.__class__.__name__ \
                + "(name=\"%s\", dtype=%s, value=%s, doc=\"%s\", constraint=%s" \
                %(self._name, self._dtype.__name__, self._value.__repr__(), self.__doc__, \
                self._constraint.__repr__())
        for k, v in self.addattr.iteritems():
            repr_s += ", %s=%s" %(str(k), v.__repr__())
        repr_s += ")"
        return repr_s

    #
    # Conversions methods
    #
    def __str__(self):
        return str(self._value)

    def __int__(self):
        return int(self._value)

    def __long__(self):
        return long(self._value)

    def __float__(self):
        return float(self._value)

    def __oct__(self):
        return oct(self._value)

    def __hex__(self):
        return hex(self._value)

    #FIXME: not exactly right
    def tolist(self):
        if len(self) > 1:
            return list(self._value)
        else:
            return [self._value]


cdef int propertylist_id = 0
cdef class PropertyList:
    """"
    PropertyList is an in-between List-Dictionary structure to hold Property attributes.

    PropertyList will act as an ordered __dict__ for an object to hold their Property
    attributes and group them in an meaningful way for end user presentation.
    PropertyList could be easly written to disk (or dump in memory) for application
    parameters persistence. The XML output expose the attribute's values of an object
    in an ordered, hierarchical and human readable way.
    Grouping proceed in a flat form, that's it, property can only sit at the root or in a group,
    a group can't be add to a group.
    """
    cdef list plist
    cdef object _group
    cdef str _name
    cdef object __doc__
    cdef object XML_tree
    cdef int _id
    cdef list addxmlattr
    cdef object encoding
    cdef public unicode version
    cdef int groupe_marker

    def __init__(PropertyList self, name=None, doc=None,
                version='0.0', encoding='us-ascii', *args, **kwargs):
        global propertylist_id
        self._group = ODict()
        self.groupe_marker = 0
        self.plist = []
        self._name = str(name) if name is not None else  "propertylist_" + str(self._id)
        propertylist_id += 1
        self.__doc__ = str(doc) if doc is not None else ""
        self.addxmlattr = []
        self.setxmlencoding(encoding)
        self.version = version

    #
    # PropertList Group Method
    #
    def ingroup(PropertyList self, Property p):
        if not isinstance(p, Property):
            raise TypeError("Need a Property instance not %s" %str(type(p)))
        if p is None:
            return None
        for name, group in self._group.items():
            if p in group[1]:
                return name

    def addgroup(PropertyList self, name, doc=None, start=None, end = None):
        for n in self._group.keys():
            if name == n:
                raise ValueError("A group with name %s already defined" %name)
        if start is not None:
            end = start + 1 if end is None else end + 1
        elif end == -1:
            start = self.groupe_marker
            end = self.__len__()
        else:
            start = end = 0

        group = [self.plist[i] for i in range(start, end)]
        for n, gr in self._group.items():
            for prop in group:
                if prop in gr[1]:
                    raise ValueError("Try to define a group that intersect with group %s" %n)
        self.groupe_marker = end

        doc = "" if doc is None else doc
        self._group[name] = (doc, group)

    def addtogroup(PropertyList self, name, start, end = None):
        gr = self._group[name]
        end = start + 1 if end is None else end
        group = [self.plist[i] for i in range(start, end)]
        for n, grs in self._group.items():
                for prop in group:
                    if prop in grs[1]:
                        raise ValueError("Try to add a property already in group %s" %n)
        #Note: group could finished unordered
        gr[1] += group

    #
    #   Attributes And Descriptors
    #
    def __getattr__(PropertyList self, name):
        b, i = self._contains(name)
        if b:
            return self.plist[i]
        else:
            raise AttributeError("No attribute with this name (%s)" %name)

    def __setattr__(PropertyList self, name, val):
        contain, indice = self._contains(name)
        if contain:
            self.plist[indice].value = val
        else:
            if isinstance(val, Property):
                self._append(val)
            elif isinstance(val, dict):
                p = Property(name=name, **val)
                self._append(p)
            elif isinstance(val, tuple):
                li = []
                di = {}
                for v in val:
                    if not isinstance(v, dict):
                        li.append(v)
                    else:
                        for k,j in v.iteritems():
                            di[k] = j
                p = Property(name, *li, **di)
                self.append(p)
            else:
                raise TypeError("can't add a Property with object of type %s : %s" %(val.__class__.__name__, val))

    property name:
        def __get__(self):
            return self._name

    property doc:
        def __get__(self):
            return self.__doc__

    property __doc__:
        def __get__(self):
            return self.__doc__

    #
    # Collection Methods
    #
    def __getitem__(PropertyList self, Py_ssize_t indice):
        return self.plist[indice]

    def __setitem__(PropertyList self, Py_ssize_t indice, prop):
        if not isinstance(prop, Property):
            raise TypeError("PropertyList can only store Property, not %s" %str(type(prop)))
        else:
            contain, i = self._contains(prop.name)
            if contain and i != indice:
                raise ValueError("A Property with the same name (%s) already exist" %prop.name)
            else:
                group = self.ingroup(self.plist[indice])
                if group:
                    i = self._group[group][1].index(self.plist[indice])
                    self._group[group][1][i] = prop
                self.plist[indice] = prop

    def __delitem__(PropertyList self, Py_ssize_t indice):
        group = self.ingroup(self.plist[indice])
        if group:
             i = self._group[group][1].index(self.plist[indice])
             del self._group[group][1][i]
        del self.plist[indice]

    def append(PropertyList self, *args, **kwargs):
        if isinstance(args[0], Property):
            self._append(args[0])
        else:
            p = Property(*args, **kwargs)
            self._append(p)

    cdef _append(PropertyList self, o):
        contain, i = self._contains(o.name)
        if contain:
            raise ValueError("A Property with the same name (%s) already exist" %o.name)
        else:
            self.plist.append(o)

    def index(PropertyList self, o):
        if not isinstance(o, Property):
            raise TypeError("PropertyList can only contains Property (not %s)" %str(type(o)))
        return self.plist.index(o)

    cpdef _contains(PropertyList self, name):
        cdef Property p
        cdef int i
        for i in range(len(self.plist)):
            if self.plist[i].name == name:
                return (True,i)
        return (False,None)

    def __contains__(PropertyList self, prop):
        return prop in self.plist

    def __len__(PropertyList self):
        return len(self.plist)

    def __iter__(PropertyList self):
        return self.plist.__iter__()

    def __next__(PropertyList self):
        return self.plist.__next__()

    def __reversed__(PropertyList self):
        return self.plist.__reversed__()

    def __add__(PropertyList self, PropertyList prop_l):
        if not isinstance(prop_l, PropertyList):
            raise TypeError("can only concatenate PropertyList (not %s) to PropertyList" %str(type(prop_l)))
        for p in prop_l:
            contain, i = self._contains(p.name)
            if contain:
                raise ValueError("A Property with the name (%s) already exist" %p.name)
        self.plist += prop_l.plist

    #
    # Conversion Method
    #
    def __repr__(PropertyList self):
        return self.plist.__repr__()

    def tolist(PropertyList self):
        return self.plist

    def __str__(self):
        return self.toxmlstring()

    #
    # XML
    #
    def getxmlencoding(self):
        return self.encoding

    def setxmlencoding(self, encoding):
        try:
            c = codecs.lookup(encoding)
        except LookupError as e:
            raise e
        else:
            self.encoding = c.name

    cpdef set_xmlexportattr(PropertyList self, object ad):
        base = ['value', 'doc', '__doc__', 'dtype']
        self.addxmlattr = []
        if isinstance(ad,(list, tuple)):
            for a in ad:
                if not str(a) in base:
                    self.addxmlattr.append(str(a))
        else:
            if not str(ad) in base:
                self.addxmlattr.append(str(ad))

    cpdef get_xmlexportattr(PropertyList self):
        return self.addxmlattr

    cpdef getxmltree(PropertyList self):
        self._updateXML()
        return self.XML_tree

    cpdef toxmlstring(PropertyList self, encoding=None):
        if encoding is None:
            encoding = self.getxmlencoding()
        s_xml = ETree.tostring(self.getxmltree().getroot(), encoding=encoding, method='xml')
        s_pretty = minidom.parseString(s_xml)
        return s_pretty.toprettyxml(indent="    ")

    cdef _getdatestring(self):
        d = datetime.datetime.now().__str__()
        d = d[:d.find('.')]
        return d

    cdef _updateXML(PropertyList self):
        # brutal way of updating xml
        # clean the whole tree and do the job
        root = ETree.Element(tag="PropertyList")
        comment = ETree.Comment("Gravure.property.PropertyList")
        root.append(comment)
        root.set('name', self._name)
        root.set('doc', self.__doc__)
        root.set('encoding', self.getxmlencoding())
        root.set('version', self.version)
        root.set('date_modification', self._getdatestring())
        self.XML_tree = ETree.ElementTree(element=root, file=None)

        for prop in self.plist:
            added = False
            group = self.ingroup(prop)
            el = self._proptoxml(prop)
            if not group:
                root.append(el)
            else:
                g = root.iterfind("ui_group")
                for e in g:
                    if e.get("name") == group:
                        e.append(el)
                        added = True
                        break
                if not added:
                    g = self._grouptoxml(group)
                    g.append(el)
                    root.append(g)

    cdef _grouptoxml(PropertyList self, name):
        el = ETree.Element(tag="ui_group")
        el.set("name", name)
        el.set("doc", self._group[name][0])
        return el

    cdef _proptoxml(PropertyList self, Property prop):
        # tag is set to dtype
        el = ETree.Element(tag=prop.dtype.tostring())

        # basic attributtes always set
        el.set("name", prop.name)

        if prop.__doc__ != "":
            el.set("doc", prop.__doc__.splitlines()[0])
        else:
            el.set("doc", prop.__doc__)

        el.set('value', str(prop.value))

        # additional attributes defined by user if find
        for attr in self.addxmlattr:
            if hasattr(prop, attr):
                el.set(attr, str(prop.__getattr__(attr)))
        return el


