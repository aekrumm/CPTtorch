TORCH_DEVICE <- torch_device("cpu")

# Default to CPU. CUDA auto-detects on Linux GPU boxes; MPS (Apple Silicon)
# is opt-in only — set CPTTORCH_DEVICE=mps to enable. We don't auto-select
# MPS because there are still device-split paths in CPTtorch + bayestensor
# that crash on mixed cpu/mps tensors during fit_cdm.
.onLoad <- function(libname, pkgname) {
  forced <- Sys.getenv("CPTTORCH_DEVICE", unset = "")
  device <- if (nzchar(forced)) {
    torch_device(forced)
  } else if (cuda_is_available()) {
    torch_device("cuda")
  } else {
    torch_device("cpu")
  }
  assign(
    x = "TORCH_DEVICE",
    value = device,
    envir = parent.env(environment())  # package namespace
  )
}

.onAttach <- function(libname, pkgname) {
  forced <- Sys.getenv("CPTTORCH_DEVICE", unset = "")
  if (!nzchar(forced) && backends_mps_is_available() && !cuda_is_available()) {
    packageStartupMessage(
      "CPTtorch: Apple Silicon detected; running on CPU. ",
      "Set CPTTORCH_DEVICE=mps to opt into MPS acceleration ",
      "(experimental — known device-split issues in fit_cdm)."
    )
  }
}
