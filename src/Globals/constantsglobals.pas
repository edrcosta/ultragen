unit ConstantsGlobals;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  LANG_EXT = '.ultra';
  INIT_MODULE = '_init.ultra';

  EXT_SEP = '.';
  PARAM_OPEN = '(';
  PARAM_CLOSE = ')';
  PARAM_SEP = ',';
  COMMA = 'COMMA';
  STR_ENCLOSE = '''';
  ESCAPER = '\';
  ATTR_ACCESSOR = '.';
  EXT_FUNC_SEP = ':';
  REFER_VAR = '&';
  FROM_GEN_SET = '$';
  SELF_WORD = 'self';
  FUNCTION_ALLOWED = '_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  VARS_ALLOWED = '_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  NUMBERS = '1234567890';
  FUNC_SYMBOLS = '._:';
  DEF_DELIM = ',';
  EXTENSION_CALL = '>';

  AS_STRING = True;
  GEN_FILES_CALL_SEP = '|';
  SCRIPT_MODE_ENTER = '@{';
  SCRIPT_MODE_EXIT = '}';
  GEN_SUB_LEVEL = '.';
  ARROW_OPER = '^';

  { calling modes }
  SET_GROUP = '+';
  SET_SEP = '|';

  GENSET_CALL = '--gens';
  GENSET_CALL_S = '-g';
  GENPATH_CALL = '--genpath';
  GENPATH_CALL_S = '-gp';
  TEMPSET_CALL = '-templates';
  LOOK_SUB_FLAG = '-sub';
  PARAM_SET_DEFAULT = '-default';

  LIVE_CALL = '--persist';
  LIVE_CALL_S = '-p';
  GEN_AS_STRING = '--string';
  GEN_AS_STRING_S = '-s';
  SEPARATOR_CHANGE = ' -separator:';
  DEFAULT_CHANGE = ' -default:';
  ENABLE_THREADS = '--threads';

  ASC = 'ASC';
  DESC = 'DESC';

  LANG_FALSE = 'false';
  LANG_TRUE = 'true';

  UTC_FORMAT = 'ddd, dd mmm yyyy hh:nn:ss "UTC"';
  DATE_INTERCHANGE_FORMAT = 'yyyy-mm-dd hh:nn:ss.zzz';

  MULTI_LINE = ' ++';

  VERSION = '0.7';



implementation

end.
