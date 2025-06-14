# mi_thermo_reader

A flutter app for connecting to bluetooth thermometers, then reading and visualizing the stored sensor history.

## Run integration tests

There are integration tests, configured to dump screenshots with a custom driver. Run the command

    flutter drive --target=integration_test/app_test.dart --driver=test_driver/integration_test.dart