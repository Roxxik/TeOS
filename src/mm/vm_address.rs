struct VmAddress(u64);

impl VmAddress {
    pub fn new(address: u64) -> VmAddress {
        VmAddress(address)
    }

    pub fn get_pml4ti(&self) -> u64 {
        (self.0 >> 39) & 0x1FF
    }

    pub fn get_pdpti(&self) -> u64 {
        (self.0 >> 30) & 0x1FF
    }

    pub fn get_pdti(&self) -> u64 {
        (self.0 >> 21) & 0x1FF
    }

    pub fn get_pti(&self) -> u64 {
        (self.0 >> 12) & 0x1FF
    }

    pub fn get_page_offset(&self) -> u64 {
        self.0 & 0xFFF
    }
}
