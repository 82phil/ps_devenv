import json
import sys

obj = {}
obj["versionInfo"] = sys.version_info[:4]
obj["is64Bit"] = sys.maxsize > 2**32

print(json.dumps(obj))
