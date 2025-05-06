use std::path::PathBuf;

pub fn join_paths(paths: &[&str]) -> String {
    let mut buf = PathBuf::new();
    for p in paths {
        buf.push(p);
    }
    // Convert to a UTF-8 string. If the path contains non-UTF-8 data,
    // `to_string_lossy()` will substitute invalid sequences with �.
    buf.to_string_lossy().to_string()
}
