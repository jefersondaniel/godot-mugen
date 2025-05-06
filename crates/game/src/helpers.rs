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

pub fn map_io_error(error: std::io::Error) -> anyhow::Error {
    anyhow::anyhow!("IO error: {}", error)
}

pub fn get_directory(filepath: &str) -> String {
    let mut path_buf = PathBuf::from(filepath);
    path_buf.pop();
    path_buf.to_str().unwrap().to_string()
}
