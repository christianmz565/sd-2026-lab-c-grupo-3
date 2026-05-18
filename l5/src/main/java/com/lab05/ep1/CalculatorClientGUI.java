package com.lab05.ep1;

import javax.swing.*;
import javax.swing.border.*;
import java.awt.*;
import java.awt.event.*;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.text.DecimalFormat;



public class CalculatorClientGUI extends JFrame {

    // ── RMI ──────────────────────────────────────────────────────────────────
    private ICalculator calculator;
    private boolean connected = false;

    // ── Colores ───────────────────────────────────────────────────────────────
    private static final Color BG_DARK    = new Color(13, 17, 23);
    private static final Color BG_CARD    = new Color(22, 27, 34);
    private static final Color BG_INPUT   = new Color(33, 38, 45);
    private static final Color ACCENT     = new Color(88, 166, 255);
    private static final Color ACCENT_H   = new Color(121, 192, 255);
    private static final Color SUCCESS    = new Color(63, 185, 80);
    private static final Color WARNING    = new Color(210, 153, 34);
    private static final Color DANGER     = new Color(248, 81, 73);
    private static final Color TEXT_PRI   = new Color(230, 237, 243);
    private static final Color TEXT_MUT   = new Color(125, 133, 144);
    private static final Color BORDER_C   = new Color(48, 54, 61);

    // ── Widgets ───────────────────────────────────────────────────────────────
    private JTextField fieldA, fieldB;
    private JLabel resultLabel, opLabel;
    private JLabel statusDot, statusText;
    private JTextArea historyArea;

    // Operaciones: nombre, símbolo
    private static final String[][] OPS = {
        {"Suma",        "+"},
        {"Resta",       "−"},
        {"Multiplicación", "×"},
        {"División",    "÷"},
        {"Potencia",    "^"},
    };

    private int selectedOp = 0; // índice en OPS

    public CalculatorClientGUI() {
        setTitle("Calculadora RMI — Lab 05");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setSize(680, 560);
        setMinimumSize(new Dimension(580, 480));
        setLocationRelativeTo(null);
        buildUI();
        connectRMI();
    }

    // ─────────────────────────────────────────────────────────────────────────
    private void buildUI() {
        JPanel root = new JPanel(new BorderLayout());
        root.setBackground(BG_DARK);
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
            new MatteBorder(0, 0, 1, 0, BORDER_C),
            new EmptyBorder(10, 18, 10, 18)
        ));

        JLabel title = new JLabel(" Calculadora RMI");
        title.setFont(new Font("Segoe UI", Font.BOLD, 15));
        title.setForeground(TEXT_PRI);

        JPanel statusPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT, 6, 0));
        statusPanel.setOpaque(false);

        statusDot = new JLabel("●");
        statusDot.setFont(new Font("Dialog", Font.PLAIN, 10));
        statusDot.setForeground(WARNING);

        statusText = new JLabel("Conectando...");
        statusText.setFont(new Font("Segoe UI", Font.PLAIN, 11));
        statusText.setForeground(TEXT_MUT);

        JButton reconnBtn = smallBtn("↺ Reconectar");
        reconnBtn.addActionListener(e -> connectRMI());

        statusPanel.add(statusDot);
        statusPanel.add(statusText);
        statusPanel.add(Box.createHorizontalStrut(8));
        statusPanel.add(reconnBtn);

        bar.add(title,       BorderLayout.WEST);
        bar.add(statusPanel, BorderLayout.EAST);
        return bar;
    }

    // ── Panel izquierdo: botones de operación ─────────────────────────────────
    private JPanel buildLeftPanel() {
        JPanel panel = new JPanel();
        panel.setLayout(new BoxLayout(panel, BoxLayout.Y_AXIS));
        panel.setPreferredSize(new Dimension(190, 0));
        panel.setBackground(BG_CARD);
        panel.setBorder(new CompoundBorder(
            new MatteBorder(0, 0, 0, 1, BORDER_C),
            new EmptyBorder(14, 0, 14, 0)
        ));

        JLabel header = new JLabel("  Operación");
        header.setFont(new Font("Segoe UI", Font.BOLD, 11));
        header.setForeground(TEXT_MUT);
        header.setBorder(new EmptyBorder(0, 14, 10, 0));
        header.setAlignmentX(Component.LEFT_ALIGNMENT);
        panel.add(header);

        ButtonGroup group = new ButtonGroup();
        for (int i = 0; i < OPS.length; i++) {
            final int idx = i;
            JToggleButton btn = new JToggleButton(OPS[i][1] + "  " + OPS[i][0]);
            btn.setFont(new Font("Segoe UI", Font.PLAIN, 13));
            btn.setHorizontalAlignment(SwingConstants.LEFT);
            btn.setBackground(BG_CARD);
            btn.setBorder(new EmptyBorder(10, 16, 10, 16));
            btn.setFocusPainted(false);
            btn.setOpaque(true);
            btn.setMaximumSize(new Dimension(Integer.MAX_VALUE, 44));
            btn.setAlignmentX(Component.LEFT_ALIGNMENT);
            btn.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));

            if (i == 0) btn.setSelected(true);

            btn.addMouseListener(new MouseAdapter() {
                @Override public void mouseEntered(MouseEvent e) {
                    if (!btn.isSelected()) btn.setBackground(BG_INPUT);
                }
                @Override public void mouseExited(MouseEvent e) {
                    if (!btn.isSelected()) btn.setBackground(BG_CARD);
                }
            });

            btn.addActionListener(e -> {
                selectedOp = idx;
                updateOpLabel();
                // resetear color de los demás
                for (Component c : panel.getComponents()) {
                    if (c instanceof JToggleButton tb && tb != btn) {
                        tb.setBackground(BG_CARD);
                        tb.setForeground(new Color(0,0,0));
                    }
                }
                btn.setBackground(new Color(33, 52, 78));
                btn.setForeground(ACCENT);
            });

            group.add(btn);
            panel.add(btn);
        }

        panel.add(Box.createVerticalGlue());
        return panel;
    }

    // ── Panel central ─────────────────────────────────────────────────────────
    private JPanel buildCenter() {
        JPanel center = new JPanel(new BorderLayout());
        center.setBackground(BG_DARK);

        // ── Área de cálculo ──
        JPanel calcPanel = new JPanel();
        calcPanel.setLayout(new BoxLayout(calcPanel, BoxLayout.Y_AXIS));
        calcPanel.setBackground(BG_DARK);
        calcPanel.setBorder(new EmptyBorder(28, 28, 20, 28));

        opLabel = new JLabel("Suma  (A + B)");
        opLabel.setFont(new Font("Segoe UI", Font.BOLD, 18));
        opLabel.setForeground(TEXT_PRI);
        opLabel.setAlignmentX(Component.LEFT_ALIGNMENT);

        JLabel sub = new JLabel("Ingresa los valores y presiona Calcular");
        sub.setFont(new Font("Segoe UI", Font.PLAIN, 11));
        sub.setForeground(TEXT_MUT);
        sub.setAlignmentX(Component.LEFT_ALIGNMENT);
        sub.setBorder(new EmptyBorder(4, 0, 22, 0));

        // Fila de entradas
        JPanel inputRow = new JPanel(new FlowLayout(FlowLayout.LEFT, 0, 0));
        inputRow.setOpaque(false);
        inputRow.setAlignmentX(Component.LEFT_ALIGNMENT);

        fieldA = styledField();
        fieldB = styledField();

        JLabel lblA = inputTag("A");
        JLabel lblB = inputTag("B");
        JLabel sep  = new JLabel("   y   ");
        sep.setFont(new Font("Segoe UI", Font.PLAIN, 14));
        sep.setForeground(TEXT_MUT);

        inputRow.add(lblA); inputRow.add(fieldA);
        inputRow.add(sep);
        inputRow.add(lblB); inputRow.add(fieldB);

        // Resultado
        JPanel resultRow = new JPanel(new FlowLayout(FlowLayout.LEFT, 0, 0));
        resultRow.setOpaque(false);
        resultRow.setAlignmentX(Component.LEFT_ALIGNMENT);

        JLabel eqLabel = new JLabel("=  ");
        eqLabel.setFont(new Font("Segoe UI", Font.PLAIN, 20));
        eqLabel.setForeground(TEXT_MUT);

        resultLabel = new JLabel("—");
        resultLabel.setFont(new Font("JetBrains Mono", Font.BOLD, 24));
        resultLabel.setForeground(SUCCESS);
        resultLabel.setPreferredSize(new Dimension(260, 48));
        resultLabel.setHorizontalAlignment(SwingConstants.LEFT);

        resultRow.add(eqLabel);
        resultRow.add(resultLabel);

        // Botones
        JPanel btnRow = new JPanel(new FlowLayout(FlowLayout.LEFT, 12, 0));
        btnRow.setOpaque(false);
        btnRow.setAlignmentX(Component.LEFT_ALIGNMENT);

        JButton calcBtn = accentBtn("Calcular");
        calcBtn.addActionListener(e -> doCalculate());

        JButton allBtn = smallBtn("Calcular todo");
        allBtn.addActionListener(e -> doCalculateAll());

        JButton clearBtn = smallBtn("Limpiar historial");
        clearBtn.addActionListener(e -> historyArea.setText(""));

        btnRow.add(calcBtn);
        btnRow.add(allBtn);
        btnRow.add(clearBtn);

        calcPanel.add(opLabel);
        calcPanel.add(sub);
        calcPanel.add(inputRow);
        calcPanel.add(Box.createVerticalStrut(16));
        calcPanel.add(resultRow);
        calcPanel.add(Box.createVerticalStrut(20));
        calcPanel.add(btnRow);

        // ── Historial ──
        JPanel histPanel = new JPanel(new BorderLayout());
        histPanel.setBackground(BG_DARK);
        histPanel.setBorder(new CompoundBorder(
            new MatteBorder(1, 0, 0, 0, BORDER_C),
            new EmptyBorder(0, 28, 16, 28)
        ));

        JLabel histHeader = new JLabel("Historial de operaciones");
        histHeader.setFont(new Font("Segoe UI", Font.BOLD, 11));
        histHeader.setForeground(TEXT_MUT);
        histHeader.setBorder(new EmptyBorder(10, 0, 6, 0));

        historyArea = new JTextArea();
        historyArea.setEditable(false);
        historyArea.setBackground(BG_CARD);
        historyArea.setForeground(TEXT_PRI);
        historyArea.setFont(new Font("JetBrains Mono", Font.PLAIN, 12));
        historyArea.setBorder(new EmptyBorder(8, 10, 8, 10));

        JScrollPane scroll = new JScrollPane(historyArea);
        scroll.setBorder(new LineBorder(BORDER_C, 1));
        scroll.getViewport().setBackground(BG_CARD);
        scroll.setPreferredSize(new Dimension(0, 150));

        histPanel.add(histHeader, BorderLayout.NORTH);
        histPanel.add(scroll,     BorderLayout.CENTER);

        center.add(calcPanel,  BorderLayout.CENTER);
        center.add(histPanel,  BorderLayout.SOUTH);
        return center;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Lógica RMI
    // ─────────────────────────────────────────────────────────────────────────
    private void connectRMI() {
        statusDot.setForeground(WARNING);
        statusText.setText("Conectando...");
        new SwingWorker<Boolean, Void>() {
            @Override protected Boolean doInBackground() {
                try {
                    Registry registry = LocateRegistry.getRegistry("localhost", 1099);
                    calculator = (ICalculator) registry.lookup("CalculatorService");
                    calculator.add(0, 0); // prueba
                    return true;
                } catch (Exception e) { return false; }
            }
            @Override protected void done() {
                try { connected = get(); } catch (Exception ex) { connected = false; }
                if (connected) {
                    statusDot.setForeground(SUCCESS);
                    statusText.setText("Conectado a localhost:1099");
                    appendHistory("✓ Conectado al servidor RMI (localhost:1099)");
                } else {
                    statusDot.setForeground(DANGER);
                    statusText.setText("Sin conexión");
                    appendHistory("✗ No se pudo conectar. Verifica que el servidor esté activo.");
                }
            }
        }.execute();
    }

    private void doCalculate() {
        if (!checkConnection()) return;
        double a, b;
        try {
            a = Double.parseDouble(fieldA.getText().trim().replace(",", "."));
            b = Double.parseDouble(fieldB.getText().trim().replace(",", "."));
        } catch (NumberFormatException ex) {
            resultLabel.setForeground(DANGER);
            resultLabel.setText("Valor inválido");
            return;
        }

        final int op = selectedOp;
        new SwingWorker<RCPResult, Void>() {
            @Override protected RCPResult doInBackground() throws Exception {
                return invoke(op, a, b);
            }
            @Override protected void done() {
                try {
                    RCPResult res = get();
                    showResult(res.value());
                    appendHistory(formatLine(OPS[op][0], OPS[op][1], a, b, res.value(),res.ms()));
                } catch (Exception ex) {
                    resultLabel.setForeground(DANGER);
                    resultLabel.setText("Error RMI");
                    appendHistory("✗ Error: " + ex.getCause());
                }
            }
        }.execute();
    }

    /** Ejecuta las 5 operaciones en secuencia y las muestra en el historial. */
    private void doCalculateAll() {
        if (!checkConnection()) return;
        double a, b;
        try {
            a = Double.parseDouble(fieldA.getText().trim().replace(",", "."));
            b = Double.parseDouble(fieldB.getText().trim().replace(",", "."));
        } catch (NumberFormatException ex) {
            resultLabel.setForeground(DANGER);
            resultLabel.setText("Valor inválido");
            return;
        }
        final double fa = a, fb = b;
        new SwingWorker<Void, Void>() {
            @Override protected Void doInBackground() throws Exception {
                appendHistory("── Todas las operaciones (A=" + fa + ", B=" + fb + ") ──");
                for (int i = 0; i < OPS.length; i++) {
                    try {
                        RCPResult res = invoke(i, fa, fb);
                        appendHistory(formatLine(OPS[i][0], OPS[i][1], fa, fb, res.value(), res.ms()));
                        if (i == selectedOp) SwingUtilities.invokeLater(() -> showResult(res.value()));
                    } catch (Exception ex) {
                        appendHistory("✗ " + OPS[i][0] + ": " + ex.getMessage());
                    }
                }
                return null;
            }
        }.execute();
    }

    private RCPResult invoke(int op, double a, double b) throws Exception {
        long start = System.nanoTime();
        double value=switch (op) {
            case 0 -> calculator.add(a, b);
            case 1 -> calculator.subtract(a, b);
            case 2 -> calculator.multiply(a, b);
            case 3 -> calculator.divide(a, b);
            case 4 -> calculator.power(a, b);
            default -> throw new IllegalStateException("Operación inválida");
        };
        long ms = (System.nanoTime() - start) / 1_000;
        return new RCPResult(value,ms);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────────────────
    private boolean checkConnection() {
        if (!connected) {
            JOptionPane.showMessageDialog(this,
                "No hay conexión con el servidor RMI.\nPresiona ↺ Reconectar.",
                "Sin conexión", JOptionPane.WARNING_MESSAGE);
        }
        return connected;
    }

    private void showResult(double res) {
        DecimalFormat df = new DecimalFormat("#,##0.######");
        resultLabel.setForeground(SUCCESS);
        resultLabel.setText(df.format(res));
    }

    private String formatLine(String name, String sym, double a, double b, double res, long ms) {
        DecimalFormat df = new DecimalFormat("#,##0.######");
        return String.format("  %-16s %s  %s  %s  %s  =  %s  (%d mms)",
            name, df.format(a), sym, df.format(b), " ", df.format(res), ms);
    }

    private void appendHistory(String text) {
        SwingUtilities.invokeLater(() -> {
            historyArea.append(text + "\n");
            historyArea.setCaretPosition(historyArea.getDocument().getLength());
        });
    }

    private void updateOpLabel() {
        opLabel.setText(OPS[selectedOp][0] + "  (A " + OPS[selectedOp][1] + " B)");
    }

    private JTextField styledField() {
        JTextField f = new JTextField("0");
        f.setPreferredSize(new Dimension(120, 44));
        f.setFont(new Font("JetBrains Mono", Font.PLAIN, 16));
        f.setBackground(BG_INPUT);
        f.setForeground(TEXT_PRI);
        f.setCaretColor(ACCENT);
        f.setBorder(new CompoundBorder(
            new MatteBorder(1, 0, 1, 1, BORDER_C),
            new EmptyBorder(0, 8, 0, 8)
        ));
        f.setHorizontalAlignment(JTextField.RIGHT);
        f.addActionListener(e -> doCalculate());
        return f;
    }

    private JLabel inputTag(String letter) {
        JLabel l = new JLabel(letter);
        l.setFont(new Font("Segoe UI", Font.BOLD, 14));
        l.setForeground(ACCENT);
        l.setPreferredSize(new Dimension(34, 44));
        l.setHorizontalAlignment(SwingConstants.CENTER);
        l.setBackground(BG_INPUT);
        l.setOpaque(true);
        l.setBorder(new MatteBorder(1, 1, 1, 0, BORDER_C));
        return l;
    }

    private JButton accentBtn(String text) {
        JButton btn = new JButton(text);
        btn.setFont(new Font("Segoe UI", Font.BOLD, 13));
        btn.setBackground(ACCENT);
        btn.setForeground(BG_DARK);
        btn.setBorder(new EmptyBorder(10, 24, 10, 24));
        btn.setFocusPainted(false);
        btn.setOpaque(true);
        btn.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        btn.addMouseListener(new MouseAdapter() {
            @Override public void mouseEntered(MouseEvent e) { btn.setBackground(ACCENT_H); }
            @Override public void mouseExited(MouseEvent e)  { btn.setBackground(ACCENT); }
        });
        return btn;
    }

    private JButton smallBtn(String text) {
        JButton btn = new JButton(text);
        btn.setFont(new Font("Segoe UI", Font.PLAIN, 11));
        btn.setBackground(BG_INPUT);
        btn.setForeground(TEXT_MUT);
        btn.setBorder(new CompoundBorder(
            new LineBorder(BORDER_C, 1),
            new EmptyBorder(6, 12, 6, 12)
        ));
        btn.setFocusPainted(false);
        btn.setOpaque(true);
        btn.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        btn.addMouseListener(new MouseAdapter() {
            @Override public void mouseEntered(MouseEvent e) { btn.setForeground(TEXT_PRI); }
            @Override public void mouseExited(MouseEvent e)  { btn.setForeground(TEXT_MUT); }
        });
        return btn;
    }

    // ─────────────────────────────────────────────────────────────────────────
    public static void main(String[] args) {
        try { UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName()); }
        catch (Exception ignored) {}
        SwingUtilities.invokeLater(() -> new CalculatorClientGUI().setVisible(true));
    }
    private record RCPResult(double value, long ms) {}
}
