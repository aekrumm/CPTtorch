TORCH_DEVICE <- torch_device("cpu")

.onLoad <- function(libname, pkgname) {
  forced <- Sys.getenv("CPTTORCH_DEVICE", unset = "")
  device <- if (nzchar(forced)) {
    torch_device(forced)
  } else if (cuda_is_available()) {
    torch_device("cuda")
  } else if (backends_mps_is_available()) {
    torch_device("mps")
  } else {
    torch_device("cpu")
  }
  assign(
    x = "TORCH_DEVICE",
    value = device,
    envir = parent.env(environment())  # package namespace
  )
}
