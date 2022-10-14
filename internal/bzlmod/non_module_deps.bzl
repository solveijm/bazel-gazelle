load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(
    "//internal:go_repository_cache.bzl",
    "go_repository_cache",
)
load(
    "//internal:go_repository_tools.bzl",
    "go_repository_tools",
)
load(
    "//internal:go_repository_config.bzl",
    "go_repository_config",
)

def _non_module_deps_impl(module_ctx):
    go_repository_cache(
        name = "bazel_gazelle_go_repository_cache",
        # Always provided by rules_go.
        go_sdk_name = "go_default_sdk",
        go_env = {},
    )
    go_repository_tools(
        name = "bazel_gazelle_go_repository_tools",
        go_cache = Label("@bazel_gazelle_go_repository_cache//:go.env"),
    )
    go_repository_config(
        name = "bazel_gazelle_go_repository_config",
        # Generated by the go_dep module extension.
        config = Label("@bazel_gazelle_go_repository_directives//:WORKSPACE"),
    )

    # Required when depending on org_golang_google_grpc. The patches are
    # pulled from @rules_go
    http_archive(
        name = "go_googleapis",
        # master, as of 2022-09-10
        urls = [
            "https://mirror.bazel.build/github.com/googleapis/googleapis/archive/8167badf3ce86086c69db2942a8995bb2de56c51.zip",
            "https://github.com/googleapis/googleapis/archive/8167badf3ce86086c69db2942a8995bb2de56c51.zip",
        ],
        sha256 = "b97d75f1c937ed2235c501fafc475f51a3280d26f9410831686fdfd1b4f612f9",
        strip_prefix = "googleapis-8167badf3ce86086c69db2942a8995bb2de56c51",
        patches = [
            # releaser:patch-cmd find . -name BUILD.bazel -delete
            Label("@io_bazel_rules_go//third_party:go_googleapis-deletebuild.patch"),
            # set gazelle directives; change workspace name
            Label("@io_bazel_rules_go//third_party:go_googleapis-directives.patch"),
            # releaser:patch-cmd gazelle -repo_root .
            Label("@io_bazel_rules_go//third_party:go_googleapis-gazelle.patch"),
        ],
        patch_args = ["-E", "-p1"],
    )

non_module_deps = module_extension(
    _non_module_deps_impl,
)