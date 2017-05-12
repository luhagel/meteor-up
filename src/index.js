import checkUpdates from './updates';
import modules, { loadPlugins } from './modules/';
import { registerHook } from './tasks';
import pkg from '../package.json';
import yargs from 'yargs';
import chalk from 'chalk';
import MupAPI from './mup-api';

function addModuleCommands(builder, module) {
  Object.keys(module.commands).forEach(commandName => {
    let command = module.commands[commandName];
    command.builder = command.builder || {};
    builder.command(
      commandName,
      command.description,
      command.builder,
      commandWrapper(command.handler)
    );
  });
}

function filterArgv() {
  const unwanted = ['_', '$0', 'settings', 'config'];
  let result = [...yargs.argv._];

  Object.keys(yargs.argv).forEach(key => {
    if (
      unwanted.indexOf(key) === -1 &&
      yargs.argv[key] !== false &&
      yargs.argv[key] !== undefined
    ) {
      result.push(`--${key}`);

      if (typeof yargs.argv[key] !== 'boolean') {
        result.push(yargs.argv[key]);
      }
    }
  });

  return result;
}

function commandWrapper(handler) {
  return function() {
    checkUpdates()
      .then(() => {
        const api = new MupAPI(process.cwd(), filterArgv(), yargs.argv);

        let potentialPromise = handler(api);

        if (potentialPromise && typeof potentialPromise.then === 'function') {
          potentialPromise.catch(e => {
            if (e.nodemiralHistory instanceof Array) {
              // Error is form nodemiral when running a task list.
              // Nodemiral already displayed the error
              return;
            }
            console.log(e);
          });
        }
      })
      .catch(e => {
        console.error(e);
      });
  };
}

// Load plugins
let config = new MupAPI(process.cwd(), process.argv, yargs.argv).getConfig(
  false
);
if (config.plugins) {
  loadPlugins(
    config.plugins.map(plugin => {
      return {
        name: plugin,
        path: plugin
      };
    })
  );
}

// Load hooks
if (config.hooks) {
  Object.keys(config.hooks).forEach(key => {
    registerHook(key, config.hooks[key]);
  });
}

let program = yargs
  .usage(`\nUsage: ${chalk.yellow('mup')} <command> [args]`)
  .version(pkg.version)
  .alias('version', 'V')
  .global('version', false)
  .option('settings', {
    description: 'Path to Meteor settings file',
    requiresArg: true,
    string: true
  })
  .option('config', {
    description: 'Path to mup.js config file',
    requiresArg: true,
    string: true
  })
  .option('verbose', {
    description: 'Print output from build and server scripts',
    boolean: true
  })
  .strict(true)
  .alias('help', 'h')
  .epilogue(
    'For more information, read the docs at https://github.com/zodern/meteor-up'
  )
  .help('help');

Object.keys(modules).forEach(moduleName => {
  if (moduleName !== 'default' && modules[moduleName].commands) {
    yargs.command(
      moduleName,
      modules[moduleName].description,
      subYargs => {
        addModuleCommands(subYargs, modules[moduleName], moduleName);
      },
      () => {
        yargs.parse(`mup ${moduleName} help`);
      }
    );
  } else if (moduleName === 'default') {
    addModuleCommands(yargs, modules[moduleName], moduleName);
  }
});

program = program.argv;

if (program._.length === 0) {
  yargs.showHelp();
}
