# frozen_string_literal: true

# An icon-only "Expand all / Collapse all" toggle for a group of <details>
# elements. The button shows a single Lucide icon that swaps between
# `chevrons-up-down` (expand) and `chevrons-down-up` (collapse) to reflect the
# current state; the accessible name (aria-label) and aria-expanded state are
# driven by client-side JS (the inline scripts in the account sidebar and the
# dashboard balance sheet). This component renders the static shell: the
# <button>, the data attributes those scripts key off, the two icons (with the
# collapse icon hidden by default), and the initial aria-label.
#
# The icon swap is done in JS by toggling each icon's `style.display` (not via
# a Tailwind `group-aria-expanded:` variant) on purpose: the running Docker
# image ships a precompiled Tailwind bundle, so a newly introduced variant
# class would not be present in that CSS and the icons would not swap on a
# bind-mounted deploy. Inline `style.display` works regardless of the compiled
# bundle.
#
# The two labels are localized at the call site and passed in; they are stored
# in data-expand-label / data-collapse-label so the scripts can update the
# aria-label without re-rendering. The component stays locale-agnostic (this is
# what removes the "localization-bound" text the maintainer asked to drop).
#
# `data:` carries the presence marker the scripts select on
# (e.g. `account_sidebar_expand_all:` / `balance_sheet_expand_all:`). It is
# passed as `true` so Rails renders a bare `data-...` attribute; a `nil`
# value would be dropped by the tag helper and break the selector.
#
# `variant:` picks the chrome.
#   :outline (default) — bordered square for toolbars such as the account
#     sidebar, where it sits next to an outlined "New" button.
#   :ghost — borderless 24px square with a 14px icon, matching the other
#     icon buttons in a dashboard section header's hover cluster.
class DS::ExpandToggle < DesignSystemComponent
  # Shared icon-only outline style. The button is a compact square: centered
  # icon, 8px padding (32px total with the 16px icon), the same border and
  # background as the previous labelled button. The sidebar call site appends
  # `shrink-0` so the button does not compress next to the flex-1 "New" link.
  DEFAULT_CLASSES = "inline-flex items-center justify-center rounded-lg border border-primary bg-container p-2 text-primary hover:bg-surface-inset transition-colors"
  GHOST_CLASSES = "flex items-center justify-center w-6 h-6 rounded-md text-secondary hover:text-primary hover:bg-container-inset-hover transition-colors"
  VARIANTS = %i[outline ghost].freeze

  attr_reader :expand_label, :collapse_label, :data, :extra_classes, :variant

  def initialize(expand_label:, collapse_label:, data:, class_name: nil, variant: :outline)
    @expand_label = expand_label
    @collapse_label = collapse_label
    @data = data
    @extra_classes = class_name
    @variant = variant.to_sym

    raise ArgumentError, "variant: must be one of #{VARIANTS.inspect}" unless VARIANTS.include?(@variant)
  end

  def icon_classes
    "!w-3.5 !h-3.5" if variant == :ghost
  end

  def merged_opts
    {
      type: "button",
      class: class_names(variant == :ghost ? GHOST_CLASSES : DEFAULT_CLASSES, extra_classes),
      data: data.merge(expand_label: expand_label, collapse_label: collapse_label),
      aria: { expanded: false, label: expand_label }
    }
  end
end
