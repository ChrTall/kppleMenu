.pragma library
.import org.kde.plasma.core as PlasmaCore


const defaultIconName = "start-here-kde-symbolic";

function iconOrDefault(formFactor, preferredIconName) {
    // Vertical panels must have an icon, at least a default one.
    return (formFactor === PlasmaCore.Types.Vertical && preferredIconName === "")
        ? defaultIconName : preferredIconName;
}
