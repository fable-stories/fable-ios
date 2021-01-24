#!/usr/bin/python3

import os
import git
import yaml
import glob

native_libs = {
    "Combine",
    "Foundation",
    "UIKit",
    "SwiftUI",
    "AVFoundation",
    "Cocoa",
    "Dispatch",
    "XCTest",
    "PackageDescription",
    "Accelerate",
    "CoreImage",
    "CoreGraphics",
    "Darwin",
    "Photos",
    "AVKit",
    "AppKit",
    "os"
}

# TODO - read from Podfile
pod_libs = {
    "AgoraRtcKit",
    "TensorFlowLite"
}

project_module = "project_module.yml"
project_package = "project_package.yml"
debug = False


def printd(value, end="\n"):
    if debug:
        print(value, end=end)


def openyaml(_filename):
    return yaml.load(stream=open(_filename, 'r'), Loader=yaml.FullLoader)


def getmodulemap():
    # changed_files = git_repo.git.diff("HEAD", **{"name-only": True}).split("\n")
    modules = os.listdir(module_dir)
    module_map = {}
    for module in modules:
        path = "Module/" + module + "/**/*.swift"
        files = list(filter(lambda x: "Tests" not in x, glob.glob(path, recursive=True)))
        if len(files) == 0:
            continue
        deps = module_map.get(module, set())
        for file in files:
            with open(file) as fp:
                filename = os.path.splitext(file.split("/")[-1])[0]
                for l in fp.readlines():
                    line = l.replace("\n", "")
                    if line.startswith("import "):
                        dep = line.split(" ")[-1]
                        if dep in native_libs or dep in pod_libs:
                            continue
                        deps.add(dep)
                        module_map[module] = deps
    return module_map


def gettargetset(_target):
    target_set = set()
    for target_dep in _target.get("dependencies", {}):
        if "target" in target_dep:
            target_dep = target_dep["target"].split("_")[0]
            target_set.add(target_dep)
        elif "package" in target_dep:
            target_dep = target_dep["package"].split("_")[0]
            target_set.add(target_dep)
        # elif "sdk" in target_dep:
        #     target_dep = target_dep["sdk"].split("_")[0]
        #     target_set.add(target_dep)
    return target_set


def printset(title="", _set=set(), suffix=""):
    if len(_set) != 0:
        printd("", end=title)
        for s in sorted(_set):
            printd("\t" + s)
        printd("", end=suffix)


def printsetoneline(prefix="", _set=set(), suffix=""):
    if len(_set) != 0:
        printd(prefix + repr(_set) + suffix)


def writefile(file, filename, extension, lines):
    open(file, 'w').writelines(lines)
    printd("Wrote to file... %s.%s" % (filename, extension))


class CustomDumper(yaml.Dumper):
    def increase_indent(self, flow=False, indentless=False):
        return super(CustomDumper, self).increase_indent(flow, False)


print("Analyzing...", end="")

git_repo = git.Repo("./", search_parent_directories=True)
git_root = git_repo.git.rev_parse("--show-toplevel")
module_dir = git_root + "/Module"

module_map = getmodulemap()

project_package_yml = openyaml(git_root+"/"+project_package)
project_module_yml = openyaml(git_root+"/"+project_module)

all_modules = project_module_yml["targets"]
all_packages = set(project_package_yml["packages"].keys())
printset("\n-- ALL SWIFT PACKAGES --\n\n", all_packages, "\n")

# loop through all targets on module file
write_modules = {}
write_targets = write_modules.get("targets", {})

for module in all_modules:
    if module not in module_map:
        write_targets[module] = all_modules[module]
    if module in module_map:
        printd("Analyzing " + module + "...")
        verified_target_deps = []
        target_body = all_modules[module]
        target_deps = all_modules[module].get("dependencies", [])
        yaml_set = gettargetset(target_body)
        swift_set = module_map[module]
        printset("\n-- YAML Imports -- \n\n", yaml_set)
        printset("\n-- SWIFT Imports --\n\n", swift_set)
        remove_set = yaml_set.difference(swift_set)
        add_set = swift_set.difference(yaml_set)

        all_deps = []

        if len(remove_set) > 0 or len(add_set) > 0:
            target_deps = []
            package_deps = []
            write_set = yaml_set.difference(remove_set).union(add_set)
            printset("\n-- Fixed Imports --\n\n", write_set, "\n")

            for target in write_set:
                if target in all_packages:
                    package_deps.append({"package": target})
                else:
                    target_deps.append({"target": target + "_${platform}"})

            target_deps = sorted(target_deps, key=lambda x: x["target"], reverse=False)
            package_deps = sorted(package_deps, key=lambda x: x["package"], reverse=False)

            all_deps = target_deps + package_deps

        if len(all_deps) > 0:
            target_body["dependencies"] = all_deps
        else:
            target_body["dependencies"] = target_deps

        write_targets[module] = target_body
    write_modules["targets"] = write_targets

print("\nFixing dependencies...")

os.remove(project_module)
with open(project_module, 'w') as write:
    yaml.dump(write_modules, write, Dumper=CustomDumper, default_flow_style=False, sort_keys=True)
print("Done!")
