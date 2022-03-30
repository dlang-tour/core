let ServiceDscr = {
  image | Str,
  container_name | Str,
  entrypoint | Array Str,
} in


let mkService : Str -> ServiceDscr = (fun img =>
  let
    name = string.replace ":" "_" img
  in {
    image = "dlangtour/%{img}",
    container_name  = name,
    entrypoint = ["/bin/tail", "-F", "missing"],
  } | ServiceDscr) in


let makeServices = (fun images =>
  array.foldl
    (fun acc img => acc & { "%{string.replace ":" "_" img}" = mkService img })
    {}
    images
) in

makeServices [
  "core-exec:dmd",
  "core-exec:dmd-beta",
  "core-exec:dmd-nightly",
  "core-exec:ldc",
  "core-exec:ldc-beta",
  "core-dreg:latest"
]
