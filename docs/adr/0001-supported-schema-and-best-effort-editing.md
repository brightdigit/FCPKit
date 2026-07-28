# ADR 0001: Supported Schema and Best-Effort Editing

- Status: Accepted
- Date: 2026-07-17

## Context

FCPKit uses XMLCoder to decode FCPXML into typed Swift values and encode those
values again. XMLCoder ignores XML attributes and elements that are not present
in the Codable model. Preserving arbitrary unsupported XML would require a
separate document representation and is outside the current product focus.

FCPKit is primarily being developed to create new FCPXML and to inspect and
edit existing files within the supported model.

## Decision

FCPKit will define and test an explicit supported FCPXML vocabulary. The typed
Codable model is authoritative for that vocabulary.

The initial evidence boundary is the current Codable model exercised against
the checked-in FCPXML 1.13 fixtures. A version number alone does not imply
complete coverage of that version; an element or attribute is supported only
when the model and round-trip tests cover it.

Editing is best effort for input containing unsupported XML:

- Supported content is decoded, exposed, mutated, and encoded through typed
  APIs.
- Unsupported content may be omitted during encoding.
- Encoding does not fail solely because unsupported content was present.
- Round-trip loss diagnostics identify dropped elements, attributes, and text.

FCPKit will not preserve unknown attributes, opaque subtrees, namespaces, or
unknown child ordering as a separate sidecar in this phase.

## Consequences

The model can remain an ordinary XMLCoder Codable layer and can be used as the
source of truth for typed document construction. Callers editing imported
files must inspect the loss report when preserving unsupported content matters.

Zero loss is evidence only for the tested supported vocabulary and fixtures;
it is not a claim of complete coverage of every Final Cut Pro export.
