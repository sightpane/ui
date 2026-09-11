---
trigger: always_on
---

# Shadcn Flutter First Rule

In the UI project (`sightpane/ui`), NEVER create or re-implement a UI component from scratch if an equivalent or foundational component already exists in `shadcn_flutter`.

1. **Check Shadcn Flutter First**:
   - Always consult the `/shadcn-flutter` skill (`.agents/skills/shadcn-flutter/SKILL.md` and `.agents/skills/shadcn-flutter/components/`) before designing, creating, or styling any UI component (e.g., `Breadcrumb`, `Accordion`, `Avatar`, `Dialog`, `Sheet`, `Popover`, `Select`, `Steps`, `Timeline`, `Tabs`, `Table`, `Badge`, `Progress`, etc.).
2. **Use Built-in Components**:
   - Use the official `shadcn_flutter` component as the base or wrapper.
   - Do not hand-roll custom widgets when `shadcn_flutter` provides the functionality, styling, animations, or accessibility out of the box.
3. **Extend or Wrap in `lib/shared/widgets/`**:
   - If project-specific tokens or defaults are required, create a clean wrapper under `lib/shared/widgets/` that delegates directly to `shadcn_flutter` rather than rebuilding the component manually.
