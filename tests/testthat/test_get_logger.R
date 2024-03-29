context("get_logger")




test_that("get_logger(): works as expected", {

  lg <- get_logger("blubb")

  expect_identical(lg$name, "blubb")
  expect_identical(lg$name, "blubb")
  expect_identical(lg$parent, lgr)

  lg1 <- get_logger("fizz")
  lg2 <- get_logger("fizz/buzz")
  lg3 <- get_logger("fizz/buzz/wuzz")

  expect_identical(lg3$parent, lg2)
  expect_identical(lg2$parent, lg1)
  expect_identical(lg1$parent, lgr::lgr)

  lg2$set_propagate(FALSE)

  expect_equal(
    unname(unclass(lg3$ancestry)),
    c(TRUE, FALSE, TRUE)
  )

  expect_equal(
    names(lg3$ancestry),
    c("fizz", "buzz", "wuzz")
  )
})




test_that("logger names can be specified using scalars or vectors", {
  lg1 <- get_logger("fizz/buzz/wuzz")
  lg2 <- get_logger(c("fizz", "buzz", "wuzz"))
  expect_identical(lg1, lg2)
})




test_that("get_logger is not confused by existing objects with the same name as logger", {
  lg1 <- get_logger("log/ger/test")
  lg2 <- get_logger("log/ger")
  expect_identical(lg1$parent, lg2)
})




test_that("is_virgin_Logger() identifies loggers without settings", {
  lg1 <- get_logger("foo/bar")
  expect_true(is_virgin_Logger("foo/bar"))
  lg1$set_threshold("off")
  expect_false(is_virgin_Logger("foo/bar"))
  lg1$set_threshold(NULL)
  expect_true(is_virgin_Logger(get_logger("foo/bar")))
})




test_that("get_logger_glue() works as expected", {
  lg <- get_logger("log/ger/test")

  expect_true(is_Logger(lg))
  expect_s3_class(get_logger_glue("log/ger"), "LoggerGlue")
  expect_s3_class(get_logger("log/ger"), "LoggerGlue")
  expect_identical(lg$parent, get_logger("log/ger"))
  lg$config(NULL)
})




test_that("get_logger_glue() succeedes to get preconfigured glue loggers", {
  lg <- get_logger_glue("log/ger/test")
  lg$set_threshold("fatal")
  lg <- get_logger_glue("log/ger/test")
  expect_s3_class(lg, "LoggerGlue")
  get_logger("log/ger/test", reset = TRUE)
})




test_that("get_logger_glue() fails to get preconfigured loggers that are not glue loggers", {
  lg <- get_logger("log/ger/test2")
  lg$set_threshold("fatal")
  expect_error(get_logger_glue("log/ger/test2"), "LoggerGlue")
  get_logger("log/ger/test2", reset = TRUE)
})




test_that("get_logger(reset == TRUE) completely resets logger", {
  lg <- get_logger_glue("log/ger/reset")
  lg$set_threshold("fatal")
  lg$add_appender(AppenderConsole$new())

  expect_s3_class(lg, "LoggerGlue")
  expect_identical(lg$threshold, 100L)
  expect_identical(lg, get_logger("log/ger/reset"))

  lg2 <- get_logger("log/ger/reset", reset = TRUE)
  lg1 <- get_logger("log/ger/reset")
  expect_identical(
    data.table::address(lg1),
    data.table::address(lg2)
  )

  lg_g1 <- get_logger_glue("log/ger/reset")
  lg_g2 <- get_logger_glue("log/ger/reset")
  expect_identical(lg1, lg2)
  expect_identical(
    data.table::address(lg_g1),
    data.table::address(lg_g2)
  )
  expect_false(inherits(lg2, "LoggerGlue"))
  expect_identical(lg2$threshold, 400L)
})




test_that("get_logger(reset == TRUE) invalidates old Logger", {
  lg1 <- get_logger("log/ger/reset", reset = TRUE)
  lg1$set_threshold("fatal")

  lg2 <- get_logger("log/ger/reset", reset = TRUE)$
    set_threshold("info")$
    add_appender(AppenderConsole$new())$
    set_propagate(FALSE)

  expect_true(!identical(lg1, lg2))
  expect_warning(lg1$fatal("test"), "log/ger/reset")
  expect_output(lg2$info("test"))


  # invalidation works with logger glue
  get_logger("log/ger/reset", reset = TRUE)
  lg1 <- get_logger_glue("log/ger/reset")
  lg1$set_threshold("fatal")

  lg2 <- get_logger("log/ger/reset", reset = TRUE)
  expect_true(!identical(lg1, lg2))
  expect_warning(lg1$fatal("test"), "log/ger/reset")
  expect_output(lg2$info("test"))
  get_logger("log/ger/reset", reset = TRUE)
})
