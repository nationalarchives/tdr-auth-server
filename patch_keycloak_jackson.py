import hashlib
import os
import stat
from pathlib import Path
from urllib.request import urlopen
from zipfile import ZipFile


KEYCLOAK_HOME = Path(os.environ.get("KEYCLOAK_HOME", "/opt/keycloak"))
JACKSON_VERSION = "2.21.8"
JACKSON_URL = (
    "https://repo.maven.apache.org/maven2/com/fasterxml/jackson/core/"
    f"jackson-databind/{JACKSON_VERSION}/jackson-databind-{JACKSON_VERSION}.jar"
)
JACKSON_SHA256 = "ad77f2285717e2f34c319d988b7c85783a47d0b33f33a501d1fcbf196e61bbaa"
REPLACED_ENTRIES = (
    "com/fasterxml/jackson/databind/",
    "META-INF/maven/com.fasterxml.jackson.core/jackson-databind/",
)
REPLACED_FILES = {
    "META-INF/services/com.fasterxml.jackson.core.ObjectCodec",
    "META-INF/versions/9/module-info.class",
}


def is_jackson_entry(name):
    return name.startswith(REPLACED_ENTRIES) or name in REPLACED_FILES


def is_signature_file(name):
    return name.startswith("META-INF/") and name.upper().endswith(
        (".SF", ".RSA", ".DSA", ".EC")
    )


def update_cli_jar(cli_jar, patched_jar):
    updated_cli_jar = cli_jar.with_suffix(".jar.tmp")
    with ZipFile(cli_jar) as original, ZipFile(patched_jar) as patched:
        with ZipFile(updated_cli_jar, "w") as updated:
            updated.comment = original.comment
            for entry in original.infolist():
                if is_jackson_entry(entry.filename) or is_signature_file(entry.filename):
                    continue
                updated.writestr(entry, original.read(entry))
            for entry in patched.infolist():
                if is_jackson_entry(entry.filename):
                    updated.writestr(entry, patched.read(entry))

    updated_cli_jar.chmod(stat.S_IMODE(cli_jar.stat().st_mode))
    updated_cli_jar.replace(cli_jar)


def main():
    with urlopen(JACKSON_URL, timeout=30) as response:
        jackson_jar_bytes = response.read()

    if hashlib.sha256(jackson_jar_bytes).hexdigest() != JACKSON_SHA256:
        raise SystemExit("Unexpected jackson-databind checksum")

    patched_jar = Path("/tmp/jackson-databind.jar")
    patched_jar.write_bytes(jackson_jar_bytes)

    runtime_jar = next(
        (KEYCLOAK_HOME / "lib/lib/main").glob(
            "com.fasterxml.jackson.core.jackson-databind-*.jar"
        )
    )
    runtime_jar.write_bytes(jackson_jar_bytes)

    cli_jar = next((KEYCLOAK_HOME / "bin/client").glob("keycloak-admin-cli-*.jar"))
    update_cli_jar(cli_jar, patched_jar)

    patched_jar.unlink()


if __name__ == "__main__":
    main()
