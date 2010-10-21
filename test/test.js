#!/usr/bin/env expresso

var sys = require('sys'),
    exec = require('child_process').exec;

/* The set of languages we support. 
 * Expected to be executable files in the current directory */
var langs = ['php','rb','py','java.sh'];

/* Modes that generate.php should run in. 
 * These are environment varialbes */
var types = ['ENCRYPT', 'SIGN'];

/* Modes that generate.php can make errors in.
 * These will be run for each of the "types" above.
 * It is an object of enviroment => expected error string */
var bad_cases = {
  'BAD_SIG' : 'Invalid signature',
  'BAD_ALGO' : 'Unsupported algorithm',
  'OLD_TIME' : 'Too old',
  'BAD_TIME' : 'Too old',
};

function addTest(type, lang) {
  var name = 'Good '+type+' test in '+lang;
  exports[name] = function(assert) {
    run(type+'=1', lang, function(error, stdout, stderr) {
      assert.eql(error, null, name + ' has an error output');
      assert.eql(stderr, '', name + 'has something on stderr');
      assert.includes(stdout, '"the answer is forty two"', name + ' is unexpected output');
    });
  }

  forEach(bad_cases, function(bad_expected, bad_case) {
    var env = type+'=1 ' +bad_case+'=1';
    var name = env+' test in '+lang;
    exports[name] = function(assert) {
      run(env, lang, function(error, stdout, stderr) {
        assert.includes(stderr, bad_expected, name + ' had nothing on stderr');
      });
    }
  });
}

function run(env, lang, callback) {
  sys.puts('Running '+env+' in '+lang);
  exec(env+' ./test/generate.php | ./sample.'+lang, callback);
}

/* To deal with closures in functions */
function forEach(arr, func) {
  for (var i in arr) {
    func(arr[i], i);
  }
}

/* Add the functions */
forEach(langs, function(lang) {
  forEach(types, function(type) {
    addTest(type, lang);
  });
});
