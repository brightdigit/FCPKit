# Final Cut Pro Export Recommendations for Testing FCPKit

To ensure comprehensive testing of the FCPKit schema, here are the types of projects you should export from Final Cut Pro:

## Automated Schema-Completeness Loop

Run the Swift differential harness against the checked-in exports:

```sh
swift run fcpxml-diff schema-completeness Tests/FCPKitTests/TestData \
  --markdown SCHEMA_COMPLETENESS_REPORT.md \
  --json SCHEMA_COMPLETENESS_REPORT.json
```

The command decodes each file through `FCPXMLParser`, re-encodes it through XMLCoder, normalizes resource references and volatile data, and reports structural elements, attributes, and text that the Codable model dropped. The generated Markdown and JSON reports are the prioritized input for the existing "identify missing elements -> add Codable types" loop.

As of July 2026, Final Cut Pro 12.0 exports FCPXML 1.14. Apple confirms the version in the [Final Cut Pro release notes](https://support.apple.com/en-us/102825), although the [Apple Developer DTD page](https://developer.apple.com/documentation/professional-video-applications/document-type-definition) still documents FCPXML 1.10. The current fixtures remain valid 1.13 samples, but new feature-isolation exports should use the latest available version and record it with the sample.

`MulticamXMLBuilder` constructs multicam documents through the typed Codable
model. Prefer schema-completeness and feature-pair diffs when expanding the
supported vocabulary; do not reintroduce raw XML templates for covered
structures.

## ✅ Already Tested (Included in FCPKit)

### **Interview.fcpxml** - Multicam Interview Project
- ✅ Multicam clips (`mc-clip`, `mc-source`)
- ✅ Multiple camera angles (`mc-angle`)
- ✅ Reference clips (`ref-clip`)
- ✅ Asset clips with media references
- ✅ Smart collections
- ✅ Library organization with events
- ✅ Video filters and effects
- ✅ Audio channel sources and roles

### **UntitledXML.fcpxml** - Advanced Editing Project  
- ✅ Sync clips (`sync-clip`)
- ✅ Transform adjustments (`adjust-transform`)
- ✅ Crop adjustments (`adjust-crop`)
- ✅ Video filters (`filter-video`)
- ✅ Conform rate handling
- ✅ Time mapping (`timeMap`, `timept`)
- ✅ Audio volume adjustments
- ✅ Blend modes
- ✅ Media representations (`media-rep`)

## 🔄 Recommended Additional Exports

### **1. Title-Heavy Project**
**Create a project with:**
- Basic titles (lower thirds)
- Animated titles with motion
- Custom fonts and styling
- Title templates
- Text on path animations

**Expected Elements:** `title`, `text`, `text-style`, `text-style-def`

### **2. Audio-Focused Project**
**Create a project with:**
- Audio-only clips
- Multiple audio channels
- Audio effects (EQ, compression)
- Audio transitions
- Voice isolation
- Multichannel audio (5.1 surround)

**Expected Elements:** `filter-audio`, `audio-channel-source`, `audio-role`

### **3. Transition Showcase**
**Create a project with:**
- Various video transitions (dissolve, wipe, etc.)
- Custom transition parameters
- Audio crossfades
- Speed ramps

**Expected Elements:** `transition`, various transition types

### **4. Effects and Color Correction**
**Create a project with:**
- Color correction (color wheels, curves)
- Visual effects (blur, glow)
- LUT applications
- Motion effects
- Keyframe animations

**Expected Elements:** `color-correction`, `motion`, `keyframe`, LUT references

### **5. Generator and Graphics**
**Create a project with:**
- Color mattes
- Noise generators
- Shape generators
- Custom graphics
- Background elements

**Expected Elements:** `generator`, various generator types

### **6. Markers and Metadata**
**Create a project with:**
- Timeline markers
- Chapter markers
- Keywords and tags
- Ratings (favorites, reject)
- Custom metadata
- Analysis keywords

**Expected Elements:** `marker`, `chapter-marker`, `keyword`, `rating`, metadata

### **7. Compound and Nested Elements**
**Create a project with:**
- Compound clips
- Nested sequences
- Connected storylines
- Secondary storylines
- Blade cuts and split edits

**Expected Elements:** `compound-clip`, `storyline`, `connected-clip`

### **8. Speed and Retiming**
**Create a project with:**
- Slow motion clips
- Speed ramps
- Time-lapse
- Optical flow retiming
- Frame blending

**Expected Elements:** `retime-clip`, `speed`, complex `timeMap`

### **9. Captions and Subtitles**
**Create a project with:**
- Auto-generated captions
- Manual subtitles
- Multiple caption languages
- Caption styling

**Expected Elements:** `caption`, `subtitle`, caption roles

### **10. Complex Multicam**
**Create a project with:**
- 4+ camera angles
- Audio-follows-video switching
- Multicam audio adjustments
- Angle assembly from separate files

**Expected Elements:** Enhanced `multicam`, `mc-angle` structures

## Testing Strategy

1. **Export each project as FCPXML**
2. **Add to FCPKit test suite**
3. **Run parsing tests**
4. **Identify missing elements**
5. **Add new Codable types**
6. **Validate round-trip encoding**

## Export Settings

- Use **File > Export > Final Cut Pro XML...**
- Export version: **Latest (currently 1.14)**
- Include all metadata and markers
- Export complete project structure

## Validation Checklist

For each export, verify FCPKit can handle:
- [ ] Parse without errors
- [ ] Access all major elements
- [ ] Round-trip encode/decode
- [ ] Preserve element relationships
- [ ] Handle optional attributes
- [ ] Parse complex nested structures

This comprehensive testing approach ensures FCPKit supports the full breadth of Final Cut Pro's FCPXML specification.
