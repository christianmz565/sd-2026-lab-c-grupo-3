package com.lab05.ep2;

import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import proto.ConverterGrpc;
import proto.ConvertRequest;
import proto.ConvertResponse;

import javax.swing.*;
import javax.swing.border.*;
import java.awt.*;
import java.awt.event.*;
import java.awt.geom.*;
import java.text.DecimalFormat;
import java.util.*;

/**
 * Cliente gRPC con interfaz gráfica Swing.
 * Reemplaza el menú de consola por una UI moderna.
 *
 * Dependencias: igual que el Client.java original (grpc, proto generado).
 * Para compilar junto al proyecto, reemplaza Client.java por este archivo.
 */
public class ClientGUI extends JFrame {

    // ── gRPC ──────────────────────────────────────────────────────────────────
    private ManagedChannel channel;
    private ConverterGrpc.ConverterBlockingStub stub;
    private boolean connected = false;

    // ── Colores ───────────────────────────────────────────────────────────────
    private static final Color BG_DARK      = new Color(13, 17, 23);
    private static final Color BG_CARD      = new Color(22, 27, 34);
    private static final Color BG_INPUT     = new Color(33, 38, 45);
    private static final Color ACCENT       = new Color(88, 166, 255);
    private static final Color ACCENT_HOVER = new Color(121, 192, 255);
    private static final Color SUCCESS      = new Color(63, 185, 80);
    private static final Color WARNING      = new Color(210, 153, 34);
    private static final Color TEXT_PRIMARY = new Color(230, 237, 243);
    private static final Color TEXT_MUTED   = new Color(125, 133, 144);
    private static final Color BORDER       = new Color(48, 54, 61);

    // ── Fuentes ───────────────────────────────────────────────────────────────
    private static final Font FONT_MONO  = new Font("JetBrains Mono", Font.PLAIN, 13);
    private static final Font FONT_UI    = new Font("Segoe UI", Font.PLAIN, 13);
    private static final Font FONT_TITLE = new Font("Segoe UI", Font.BOLD, 15);
    private static final Font FONT_LABEL = new Font("Segoe UI", Font.PLAIN, 11);

    // ── Conversiones disponibles ──────────────────────────────────────────────
    private static final Object[][] CONVERSIONS = {
        {"🌡  Temperatura",  null,                              null},
        {"Celsius → Fahrenheit",   "°C",  "°F"},
        {"Fahrenheit → Celsius",   "°F",  "°C"},
        {"💱  Moneda",       null,                              null},
        {"Soles → Dólares",        "S/.", "$"},
        {"Dólares → Soles",        "$",   "S/."},
        {"📏  Distancia",    null,                              null},
        {"Km → Millas",            "km",  "mi"},
        {"Millas → Km",            "mi",  "km"},
        {"⚖  Peso",         null,                              null},
        {"Kg → Libras",            "kg",  "lbs"},
        {"Libras → Kg",            "lbs", "kg"},
        {"⏱  Tiempo",       null,                              null},
        {"Horas → Minutos",        "h",   "min"},
        {"Minutos → Horas",        "min", "h"},
    };

    // ── Widgets ───────────────────────────────────────────────────────────────
    private JList<String> conversionList;
    private DefaultListModel<String> listModel;
    private JTextField inputField;
    private JLabel resultLabel;
    private JLabel unitInLabel, unitOutLabel;
    private JButton convertBtn;
    private JLabel statusDot;
    private JLabel statusText;
    private JTextArea historyArea;
    private JLabel selectedLabel;

    // mapea índice visual → índice de conversión real (saltando separadores)
    private final Map<Integer, Integer> listIndexToConversion = new LinkedHashMap<>();

    public ClientGUI() {
        setTitle("Conversor gRPC — Lab 05");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setSize(820, 600);
        setMinimumSize(new Dimension(700, 520));
        setLocationRelativeTo(null);
        setBackground(BG_DARK);

        buildUI();
        connectGRPC();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Construcción de la UI
    // ─────────────────────────────────────────────────────────────────────────
    private void buildUI() {
        JPanel root = new JPanel(new BorderLayout()) {
            @Override protected void paintComponent(Graphics g) {
                super.paintComponent(g);
                g.setColor(BG_DARK);
                g.fillRect(0, 0, getWidth(), getHeight());
            }
        };
        root.setOpaque(false);

        root.add(buildTopBar(),    BorderLayout.NORTH);
        root.add(buildLeftPanel(), BorderLayout.WEST);
        root.add(buildCenter(),    BorderLayout.CENTER);

        setContentPane(root);
    }

    // ── Barra superior ────────────────────────────────────────────────────────
    private JPanel buildTopBar() {
        JPanel bar = new JPanel(new BorderLayout());
        bar.setBackground(BG_CARD);
        bar.setBorder(new CompoundBorder(
            new MatteBorder(0, 0, 1, 0, BORDER),
            new EmptyBorder(10, 18, 10, 18)
        ));

        JLabel title = new JLabel("  Conversor gRPC");
        title.setFont(FONT_TITLE);
        title.setForeground(TEXT_PRIMARY);

        JPanel statusPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT, 6, 0));
        statusPanel.setOpaque(false);
        statusDot = new JLabel("●");
        statusDot.setForeground(WARNING);
        statusDot.setFont(new Font("Dialog", Font.PLAIN, 10));
        statusText = new JLabel("Conectando...");
        statusText.setFont(FONT_LABEL);
        statusText.setForeground(TEXT_MUTED);

        JButton reconnectBtn = smallButton("↺ Reconectar");
        reconnectBtn.addActionListener(e -> connectGRPC());

        statusPanel.add(statusDot);
        statusPanel.add(statusText);
        statusPanel.add(Box.createHorizontalStrut(8));
        statusPanel.add(reconnectBtn);

        bar.add(title, BorderLayout.WEST);
        bar.add(statusPanel, BorderLayout.EAST);
        return bar;
    }

    // ── Panel izquierdo: lista de conversiones ─────────────────────────────
    private JPanel buildLeftPanel() {
        JPanel panel = new JPanel(new BorderLayout());
        panel.setPreferredSize(new Dimension(230, 0));
        panel.setBackground(BG_CARD);
        panel.setBorder(new MatteBorder(0, 0, 0, 1, BORDER));

        JLabel header = new JLabel("  Conversiones");
        header.setFont(new Font("Segoe UI", Font.BOLD, 11));
        header.setForeground(TEXT_MUTED);
        header.setBorder(new EmptyBorder(10, 12, 6, 0));

        listModel = new DefaultListModel<>();
        int convIndex = 0;
        for (int i = 0; i < CONVERSIONS.length; i++) {
            Object[] row = CONVERSIONS[i];
            if (row[1] == null) {
                listModel.addElement("§" + row[0]); // separador
            } else {
                listModel.addElement((String) row[0]);
                listIndexToConversion.put(listModel.size() - 1, convIndex);
                convIndex++;
            }
        }

        conversionList = new JList<>(listModel);
        conversionList.setBackground(BG_CARD);
        conversionList.setForeground(TEXT_PRIMARY);
        conversionList.setFont(FONT_UI);
        conversionList.setFixedCellHeight(34);
        conversionList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        conversionList.setCellRenderer(new ConversionCellRenderer());
        conversionList.setBorder(new EmptyBorder(0, 0, 0, 0));

        // Selección inicial: primera conversión real
        for (int i = 0; i < listModel.size(); i++) {
            if (!listModel.get(i).startsWith("§")) {
                conversionList.setSelectedIndex(i);
                break;
            }
        }

        conversionList.addListSelectionListener(e -> {
            if (!e.getValueIsAdjusting()) onSelectionChange();
        });

        // impedir selección de separadores
        conversionList.addMouseListener(new MouseAdapter() {
            @Override public void mouseClicked(MouseEvent e) {
                int idx = conversionList.locationToIndex(e.getPoint());
                if (idx >= 0 && listModel.get(idx).startsWith("§"))
                    conversionList.clearSelection();
            }
        });

        JScrollPane scroll = new JScrollPane(conversionList);
        scroll.setBorder(BorderFactory.createEmptyBorder());
        scroll.setBackground(BG_CARD);
        scroll.getViewport().setBackground(BG_CARD);
        scroll.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);

        panel.add(header, BorderLayout.NORTH);
        panel.add(scroll, BorderLayout.CENTER);
        return panel;
    }

    // ── Panel central: entrada, resultado, historial ───────────────────────
    private JPanel buildCenter() {
        JPanel center = new JPanel(new BorderLayout(0, 0));
        center.setBackground(BG_DARK);

        // ── Panel de conversión ──
        JPanel convertPanel = new JPanel();
        convertPanel.setLayout(new BoxLayout(convertPanel, BoxLayout.Y_AXIS));
        convertPanel.setBackground(BG_DARK);
        convertPanel.setBorder(new EmptyBorder(28, 28, 20, 28));

        selectedLabel = new JLabel("Celsius → Fahrenheit");
        selectedLabel.setFont(new Font("Segoe UI", Font.BOLD, 18));
        selectedLabel.setForeground(TEXT_PRIMARY);
        selectedLabel.setAlignmentX(Component.LEFT_ALIGNMENT);

        JLabel subLabel = new JLabel("Ingresa el valor y presiona Convertir");
        subLabel.setFont(FONT_LABEL);
        subLabel.setForeground(TEXT_MUTED);
        subLabel.setAlignmentX(Component.LEFT_ALIGNMENT);
        subLabel.setBorder(new EmptyBorder(4, 0, 20, 0));

        // ── Fila de entrada ──
        JPanel inputRow = new JPanel(new FlowLayout(FlowLayout.LEFT, 0, 0));
        inputRow.setOpaque(false);
        inputRow.setAlignmentX(Component.LEFT_ALIGNMENT);
        inputRow.setMaximumSize(new Dimension(Integer.MAX_VALUE, 52));

        unitInLabel = new JLabel("°C");
        unitInLabel.setFont(new Font("Segoe UI", Font.BOLD, 14));
        unitInLabel.setForeground(ACCENT);
        unitInLabel.setPreferredSize(new Dimension(44, 44));
        unitInLabel.setHorizontalAlignment(SwingConstants.CENTER);
        unitInLabel.setBackground(BG_INPUT);
        unitInLabel.setOpaque(true);
        unitInLabel.setBorder(new MatteBorder(1, 1, 1, 0, BORDER));

        inputField = new JTextField("0");
        inputField.setPreferredSize(new Dimension(180, 44));
        inputField.setFont(new Font("JetBrains Mono", Font.PLAIN, 16));
        inputField.setBackground(BG_INPUT);
        inputField.setForeground(TEXT_PRIMARY);
        inputField.setCaretColor(ACCENT);
        inputField.setBorder(new MatteBorder(1, 0, 1, 0, BORDER));
        inputField.setHorizontalAlignment(JTextField.RIGHT);
        inputField.addActionListener(e -> doConvert());

        JLabel arrow = new JLabel("  →  ");
        arrow.setFont(new Font("Segoe UI", Font.PLAIN, 18));
        arrow.setForeground(TEXT_MUTED);

        inputRow.add(unitInLabel);
        inputRow.add(inputField);
        inputRow.add(arrow);

        // ── Resultado ──
        JPanel resultBox = new JPanel(new FlowLayout(FlowLayout.LEFT, 0, 0));
        resultBox.setOpaque(false);
        resultBox.setAlignmentX(Component.LEFT_ALIGNMENT);
        resultBox.setMaximumSize(new Dimension(Integer.MAX_VALUE, 52));

        resultLabel = new JLabel("—");
        resultLabel.setFont(new Font("JetBrains Mono", Font.BOLD, 20));
        resultLabel.setForeground(SUCCESS);
        resultLabel.setPreferredSize(new Dimension(180, 44));
        resultLabel.setHorizontalAlignment(SwingConstants.RIGHT);
        resultLabel.setBackground(BG_INPUT);
        resultLabel.setOpaque(true);
        resultLabel.setBorder(new CompoundBorder(
            new MatteBorder(1, 0, 1, 0, BORDER),
            new EmptyBorder(0, 8, 0, 8)
        ));

        unitOutLabel = new JLabel("°F");
        unitOutLabel.setFont(new Font("Segoe UI", Font.BOLD, 14));
        unitOutLabel.setForeground(SUCCESS);
        unitOutLabel.setPreferredSize(new Dimension(44, 44));
        unitOutLabel.setHorizontalAlignment(SwingConstants.CENTER);
        unitOutLabel.setBackground(BG_INPUT);
        unitOutLabel.setOpaque(true);
        unitOutLabel.setBorder(new MatteBorder(1, 0, 1, 1, BORDER));

        resultBox.add(resultLabel);
        resultBox.add(unitOutLabel);

        // ── Botón convertir ──
        convertBtn = new JButton("Convertir");
        convertBtn.setFont(new Font("Segoe UI", Font.BOLD, 13));
        convertBtn.setBackground(ACCENT);
        convertBtn.setForeground(BG_DARK);
        convertBtn.setBorder(new EmptyBorder(10, 24, 10, 24));
        convertBtn.setFocusPainted(false);
        convertBtn.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        convertBtn.setOpaque(true);
        convertBtn.setAlignmentX(Component.LEFT_ALIGNMENT);
        convertBtn.addActionListener(e -> doConvert());
        convertBtn.addMouseListener(new MouseAdapter() {
            @Override public void mouseEntered(MouseEvent e) { convertBtn.setBackground(ACCENT_HOVER); }
            @Override public void mouseExited(MouseEvent e)  { convertBtn.setBackground(ACCENT); }
        });

        JButton clearBtn = smallButton("Limpiar historial");
        clearBtn.setAlignmentX(Component.LEFT_ALIGNMENT);
        clearBtn.addActionListener(e -> historyArea.setText(""));

        JPanel btnRow = new JPanel(new FlowLayout(FlowLayout.LEFT, 12, 0));
        btnRow.setOpaque(false);
        btnRow.setAlignmentX(Component.LEFT_ALIGNMENT);
        btnRow.add(convertBtn);
        btnRow.add(clearBtn);

        convertPanel.add(selectedLabel);
        convertPanel.add(subLabel);
        convertPanel.add(inputRow);
        convertPanel.add(Box.createVerticalStrut(12));
        convertPanel.add(resultBox);
        convertPanel.add(Box.createVerticalStrut(20));
        convertPanel.add(btnRow);

        // ── Historial ──────────────────────────────────────────────────────
        JPanel histPanel = new JPanel(new BorderLayout());
        histPanel.setBackground(BG_DARK);
        histPanel.setBorder(new CompoundBorder(
            new MatteBorder(1, 0, 0, 0, BORDER),
            new EmptyBorder(0, 28, 0, 28)
        ));

        JLabel histHeader = new JLabel("Historial de conversiones");
        histHeader.setFont(new Font("Segoe UI", Font.BOLD, 11));
        histHeader.setForeground(TEXT_MUTED);
        histHeader.setBorder(new EmptyBorder(10, 0, 6, 0));

        historyArea = new JTextArea();
        historyArea.setEditable(false);
        historyArea.setBackground(BG_CARD);
        historyArea.setForeground(TEXT_PRIMARY);
        historyArea.setFont(new Font("JetBrains Mono", Font.PLAIN, 12));
        historyArea.setBorder(new EmptyBorder(8, 10, 8, 10));
        historyArea.setLineWrap(false);

        JScrollPane histScroll = new JScrollPane(historyArea);
        histScroll.setBorder(new LineBorder(BORDER, 1));
        histScroll.setBackground(BG_CARD);
        histScroll.getViewport().setBackground(BG_CARD);
        histScroll.setPreferredSize(new Dimension(0, 140));

        histPanel.add(histHeader, BorderLayout.NORTH);
        histPanel.add(histScroll, BorderLayout.CENTER);
        histPanel.add(Box.createVerticalStrut(16), BorderLayout.SOUTH);

        center.add(convertPanel, BorderLayout.CENTER);
        center.add(histPanel,    BorderLayout.SOUTH);

        return center;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Lógica
    // ─────────────────────────────────────────────────────────────────────────

    private void connectGRPC() {
        statusDot.setForeground(WARNING);
        statusText.setText("Conectando...");
        new SwingWorker<Boolean, Void>() {
            @Override protected Boolean doInBackground() {
                try {
                    if (channel != null && !channel.isShutdown()) channel.shutdown();
                    channel = ManagedChannelBuilder
                        .forAddress("localhost", 50051)
                        .usePlaintext()
                        .build();
                    stub = ConverterGrpc.newBlockingStub(channel);
                    // Prueba rápida
                    ConvertRequest req = ConvertRequest.newBuilder().setInput(0).build();
                    stub.convertCelsiusToFahrenheit(req);
                    return true;
                } catch (Exception e) {
                    return false;
                }
            }
            @Override protected void done() {
                try {
                    connected = get();
                } catch (Exception ex) { connected = false; }
                if (connected) {
                    statusDot.setForeground(SUCCESS);
                    statusText.setText("Conectado a localhost:50051");
                    appendHistory("✓ Conectado al servidor gRPC (localhost:50051)");
                } else {
                    statusDot.setForeground(new Color(248, 81, 73));
                    statusText.setText("Sin conexión");
                    appendHistory("✗ No se pudo conectar. Verifica que el servidor esté activo.");
                }
            }
        }.execute();
    }

    private void onSelectionChange() {
        int idx = conversionList.getSelectedIndex();
        if (idx < 0 || listModel.get(idx).startsWith("§")) return;

        Object[] row = getConversionRow(idx);
        selectedLabel.setText((String) row[0]);
        unitInLabel.setText((String) row[1]);
        unitOutLabel.setText((String) row[2]);
        resultLabel.setText("—");
        inputField.selectAll();
        inputField.requestFocus();
    }

    private void doConvert() {
        if (!connected) {
            JOptionPane.showMessageDialog(this,
                "No hay conexión con el servidor.\nPresiona ↺ Reconectar.",
                "Sin conexión", JOptionPane.WARNING_MESSAGE);
            return;
        }
        int listIdx = conversionList.getSelectedIndex();
        if (listIdx < 0 || listModel.get(listIdx).startsWith("§")) {
            JOptionPane.showMessageDialog(this, "Selecciona una conversión.", "Aviso", JOptionPane.INFORMATION_MESSAGE);
            return;
        }

        double input;
        try {
            input = Double.parseDouble(inputField.getText().trim().replace(",", "."));
        } catch (NumberFormatException ex) {
            resultLabel.setForeground(new Color(248, 81, 73));
            resultLabel.setText("Error");
            return;
        }

        ConvertRequest req = ConvertRequest.newBuilder().setInput(input).build();
        Integer convIdx = listIndexToConversion.get(listIdx);
        if (convIdx == null) return;

        Object[] row = getConversionRow(listIdx);
        String name     = (String) row[0];
        String unitIn   = (String) row[1];
        String unitOut  = (String) row[2];

        new SwingWorker<GRPCResult, Void>() {
            @Override protected GRPCResult doInBackground() throws Exception {
                return callGRPC(convIdx, req);
            }
            @Override protected void done() {
                try {
                    GRPCResult res = get();
                    DecimalFormat df = new DecimalFormat("#,##0.####");
                    resultLabel.setForeground(SUCCESS);
                    resultLabel.setText(df.format(res.value()));
                    String line = String.format("  %-26s %10s %-4s  →  %10s %s  (%d mms)",
                        name,
                        df.format(input), unitIn,
                        df.format(res.value()),   unitOut,
                        res.ms());
                    appendHistory(line);
                } catch (Exception ex) {
                    resultLabel.setForeground(new Color(248, 81, 73));
                    resultLabel.setText("Error RPC");
                    appendHistory("✗ Error al llamar al servidor: " + ex.getCause());
                }
            }
        }.execute();
    }

    /** Llama al método gRPC correcto según el índice de conversión real. */
    private GRPCResult callGRPC(int convIdx, ConvertRequest req) {
        // convIdx: 0-9 saltando los separadores
        // Orden: CelToF, FToCel, SolesToDol, DolToSol, KmToMi, MiToKm, KgToLbs, LbsToKg, HrsToMin, MinToHrs
        ConvertResponse resp;
        long start = System.nanoTime();
        switch (convIdx) {
            case 0:  resp = stub.convertCelsiusToFahrenheit(req);  break;
            case 1:  resp = stub.convertFahrenheitToCelsius(req);  break;
            case 2:  resp = stub.convertSolesToDollars(req);       break;
            case 3:  resp = stub.convertDollarsToSoles(req);       break;
            case 4:  resp = stub.convertKmToMiles(req);            break;
            case 5:  resp = stub.convertMilesToKm(req);            break;
            case 6:  resp = stub.convertKgToLbs(req);              break;
            case 7:  resp = stub.convertLbsToKg(req);              break;
            case 8:  resp = stub.convertHoursToMinutes(req);       break;
            case 9:  resp = stub.convertMinutesToHours(req);       break;
            default: throw new IllegalStateException("Índice inválido: " + convIdx);
        }
        long ms = (System.nanoTime() - start) / 1_000;
        return new GRPCResult(resp.getResult(), ms);
    }

    private Object[] getConversionRow(int listIdx) {
        // Cuenta cuántos separadores hay antes de listIdx para mapear al CONVERSIONS correcto
        int skip = 0;
        for (int i = 0; i <= listIdx; i++) {
            if (listModel.get(i).startsWith("§")) skip++;
        }
        return CONVERSIONS[listIdx]; // el listModel refleja CONVERSIONS 1:1
    }

    private void appendHistory(String text) {
        SwingUtilities.invokeLater(() -> {
            historyArea.append(text + "\n");
            historyArea.setCaretPosition(historyArea.getDocument().getLength());
        });
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helpers de UI
    // ─────────────────────────────────────────────────────────────────────────

    private JButton smallButton(String text) {
        JButton btn = new JButton(text);
        btn.setFont(new Font("Segoe UI", Font.PLAIN, 11));
        btn.setBackground(BG_INPUT);
        btn.setForeground(TEXT_MUTED);
        btn.setBorder(new CompoundBorder(
            new LineBorder(BORDER, 1),
            new EmptyBorder(6, 12, 6, 12)
        ));
        btn.setFocusPainted(false);
        btn.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        btn.setOpaque(true);
        btn.addMouseListener(new MouseAdapter() {
            @Override public void mouseEntered(MouseEvent e) { btn.setForeground(TEXT_PRIMARY); }
            @Override public void mouseExited(MouseEvent e)  { btn.setForeground(TEXT_MUTED); }
        });
        return btn;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Cell renderer personalizado para la lista
    // ─────────────────────────────────────────────────────────────────────────
    class ConversionCellRenderer extends DefaultListCellRenderer {
        @Override
        public Component getListCellRendererComponent(
                JList<?> list, Object value, int index,
                boolean isSelected, boolean cellHasFocus) {

            String text = (String) value;
            boolean isSep = text.startsWith("§");

            JLabel label = (JLabel) super.getListCellRendererComponent(
                list, isSep ? text.substring(1) : text,
                index, isSelected && !isSep, cellHasFocus && !isSep);

            label.setBackground(BG_CARD);
            label.setOpaque(true);

            if (isSep) {
                label.setFont(new Font("Segoe UI", Font.BOLD, 10));
                label.setForeground(TEXT_MUTED);
                label.setBorder(new CompoundBorder(
                    new MatteBorder(isSepFirst(index) ? 0 : 1, 0, 0, 0, BORDER),
                    new EmptyBorder(8, 12, 2, 0)
                ));
            } else if (isSelected) {
                label.setBackground(new Color(33, 52, 78));
                label.setForeground(ACCENT);
                label.setBorder(new CompoundBorder(
                    new MatteBorder(0, 2, 0, 0, ACCENT),
                    new EmptyBorder(0, 14, 0, 0)
                ));
            } else {
                label.setForeground(TEXT_PRIMARY);
                label.setBorder(new EmptyBorder(0, 16, 0, 0));
            }
            return label;
        }

        private boolean isSepFirst(int idx) {
            return idx == 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Main
    // ─────────────────────────────────────────────────────────────────────────
    public static void main(String[] args) {
        // Apariencia nativa del sistema
        try { UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName()); }
        catch (Exception ignored) {}

        // Forzar tema oscuro en scroll bars
        UIManager.put("ScrollBar.background",       BG_CARD);
        UIManager.put("ScrollBar.thumb",            BORDER);
        UIManager.put("ScrollBar.track",            BG_CARD);
        UIManager.put("ScrollBar.thumbHighlight",   TEXT_MUTED);
        UIManager.put("ScrollBar.thumbDarkShadow",  BORDER);
        UIManager.put("ScrollBar.thumbShadow",      BORDER);

        SwingUtilities.invokeLater(() -> new ClientGUI().setVisible(true));
    }
    private record GRPCResult(double value, long ms) {}
}
