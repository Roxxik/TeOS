struct VmAddress(u64);

impl VmAddress {
    pub fn new(address: u64) -> vm_address {
        VmAddress(address)
    }

    pub fn get_pml4ti(&self) -> usize {
        (self.address >> 39) & 0x1FF
    }

    pub fn get_pdpti(&self) -> usize {
        (self.address >> 30) & 0x1FF
    }

    pub fn get_pdti(&self) -> usize {
        (self.address >> 21) & 0x1FF
    }

    pub fn get_pti(&self) -> usize {
        (self.address >> 12) & 0x1FF
    }

    pub fn get_page_offset -> usize {
        self.address & 0xFFF
    }
}
