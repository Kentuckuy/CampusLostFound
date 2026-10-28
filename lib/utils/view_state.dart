// ===== VIEW STATE - ENUM STATUS STATE =====

/// Status representasi kondisi data pada Provider (P03 / P05)
/// Memenuhi spesifikasi wajib UTS:
/// - loading
/// - loaded
/// - error
/// - empty
enum ViewState { initial, loading, loaded, error, empty }
