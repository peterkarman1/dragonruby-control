FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install X11, virtual framebuffer, input tools, and screenshot utilities
RUN apt-get update && apt-get install -y \
    # X11 and virtual display
    xvfb \
    x11-utils \
    x11-xserver-utils \
    # Input simulation
    xdotool \
    # Screenshot tools
    scrot \
    imagemagick \
    # Audio (DragonRuby may need this)
    pulseaudio \
    libasound2 \
    libasound2-plugins \
    # Graphics libraries DragonRuby needs
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libglu1-mesa \
    libegl1-mesa \
    libsdl2-2.0-0 \
    libsdl2-image-2.0-0 \
    libsdl2-mixer-2.0-0 \
    libsdl2-ttf-2.0-0 \
    # Fonts
    fonts-dejavu-core \
    fonts-liberation \
    # Useful utilities
    procps \
    curl \
    unzip \
    bc \
    # VNC server for optional real-time viewing
    x11vnc \
    # Clean up
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -s /bin/bash druser && \
    mkdir -p /home/druser/game && \
    chown -R druser:druser /home/druser

# Set up display environment
ENV DISPLAY=:99
ENV SDL_VIDEODRIVER=x11
ENV SDL_AUDIODRIVER=dummy

# Working directory
WORKDIR /home/druser/game

# Copy helper scripts first (these change less often)
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY docker/screenshot.sh /usr/local/bin/screenshot.sh
COPY docker/send-input.sh /usr/local/bin/send-input.sh
COPY docker/game-control.sh /usr/local/bin/game-control.sh
COPY docker/eval.sh /usr/local/bin/eval.sh
RUN chmod +x /usr/local/bin/*.sh

# Expose webserver port for state inspection via eval API
EXPOSE 9001

# Copy Linux DragonRuby runtime files (use ARM64 for Apple Silicon compatibility)
COPY --chown=druser:druser dragonruby-linux-amd64/.dragonruby/stubs/linux-arm64 /home/druser/game/dragonruby
COPY --chown=druser:druser dragonruby-linux-amd64/font.ttf /home/druser/game/font.ttf
COPY --chown=druser:druser dragonruby-linux-amd64/dragonruby.png /home/druser/game/dragonruby.png
COPY --chown=druser:druser dragonruby-linux-amd64/dragonruby-controller.png /home/druser/game/dragonruby-controller.png
COPY --chown=druser:druser dragonruby-linux-amd64/console-logo.png /home/druser/game/console-logo.png

# Copy the .dragonruby directory (needed for runtime)
COPY --chown=druser:druser dragonruby-linux-amd64/.dragonruby /home/druser/game/.dragonruby

# Copy your game files
COPY --chown=druser:druser mygame /home/druser/game/mygame

# Make dragonruby executable
RUN chmod +x /home/druser/game/dragonruby

# Create directories for screenshots and control
RUN mkdir -p /home/druser/screenshots /home/druser/control && \
    chown -R druser:druser /home/druser/screenshots /home/druser/control

# Switch to non-root user
USER druser

# Expose VNC port (optional, for real-time viewing)
EXPOSE 5900

# Default command
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
